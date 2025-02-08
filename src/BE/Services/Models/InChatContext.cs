﻿using Chats.BE.Controllers.Chats.Chats;
using Chats.BE.DB;
using Chats.BE.DB.Enums;
using Chats.BE.DB.Jsons;
using Chats.BE.Services.Common;
using Chats.BE.Services.Models.Dtos;
using System.Diagnostics;
using System.Text;

namespace Chats.BE.Services.Models;

public class InChatContext(long firstTick)
{
    private long _preprocessTick, _firstReasoningTick, _firstResponseTick, _endResponseTick, _finishTick;
    private short _segmentCount;
    public UserModelBalanceCost Cost { get; private set; } = UserModelBalanceCost.Empty;
    private UserModel _userModel = null!;
    private InternalChatSegment _lastSegment = InternalChatSegment.Empty;
    private readonly StringBuilder _fullContent = new();
    private readonly StringBuilder _fullReasoningContent = new();

    public DBFinishReason FinishReason { get; set; } = DBFinishReason.Success;

    public async IAsyncEnumerable<InternalChatSegment> Run(decimal userBalance, UserModel userModel, IAsyncEnumerable<InternalChatSegment> segments)
    {
        _preprocessTick = _firstReasoningTick = _firstResponseTick = _endResponseTick = _finishTick = Stopwatch.GetTimestamp();
        _userModel = userModel;
        if (userModel.ExpiresAt.IsExpired())
        {
            throw new SubscriptionExpiredException(userModel.ExpiresAt);
        }
        JsonPriceConfig priceConfig = userModel.Model.ToPriceConfig();
        if (userModel.TokenBalance == 0 && userModel.CountBalance == 0 && userBalance == 0 && !priceConfig.IsFree())
        {
            throw new InsufficientBalanceException();
        }

        UserModelBalanceCalculator calculator = new(userModel.CountBalance, userModel.TokenBalance, userBalance);
        Cost = calculator.GetNewBalance(0, 0, priceConfig);
        if (!Cost.IsSufficient)
        {
            throw new InsufficientBalanceException();
        }

        try
        {
            await foreach (InternalChatSegment seg in segments)
            {
                if (seg.IsFromUpstream)
                {
                    _segmentCount++;
                    if (seg.ReasoningSegment != null)
                    {
                        if (_firstReasoningTick == _preprocessTick) // never reasoning
                        {
                            _firstReasoningTick = Stopwatch.GetTimestamp();
                        }
                    }
                    if (seg.Segment != null)
                    {
                        if (_firstResponseTick == _preprocessTick) // never response
                        {
                            _firstResponseTick = Stopwatch.GetTimestamp();
                        }
                    }
                }
                _lastSegment = seg;
                _fullContent.Append(seg.Segment);
                _fullReasoningContent.Append(seg.ReasoningSegment);

                UserModelBalanceCost currentCost = calculator.GetNewBalance(seg.Usage.InputTokens, seg.Usage.OutputTokens, priceConfig);
                if (!currentCost.IsSufficient)
                {
                    FinishReason = DBFinishReason.InsufficientBalance;
                    throw new InsufficientBalanceException();
                }
                Cost = currentCost;
                FinishReason = seg.ToDBFinishReason() ?? FinishReason;

                yield return seg;
            }
        }
        finally
        {
            _endResponseTick = Stopwatch.GetTimestamp();
        }
    }

    public InternalChatSegment FullResponse => _lastSegment with 
    { 
        Segment = _fullContent.ToString(), 
        ReasoningSegment = _fullReasoningContent.ToString() 
    };

    public int ReasoningDurationMs => (int)Stopwatch.GetElapsedTime(_firstReasoningTick, _firstResponseTick).TotalMilliseconds;

    public UserModelUsage ToUserModelUsage(int userId, ClientInfo clientInfo, bool isApi)
    {
        if (_finishTick == _preprocessTick) _finishTick = Stopwatch.GetTimestamp();

        UserModelUsage usage = new()
        {
            UserModelId = _userModel.Id,
            UserModel = _userModel,
            CreatedAt = DateTime.UtcNow,
            FinishReasonId = (byte)FinishReason,
            SegmentCount = _segmentCount,
            PreprocessDurationMs = (int)Stopwatch.GetElapsedTime(firstTick, _preprocessTick).TotalMilliseconds,
            ReasoningDurationMs = ReasoningDurationMs,
            FirstResponseDurationMs = (int)Stopwatch.GetElapsedTime(_preprocessTick, _firstReasoningTick != _preprocessTick ? _firstReasoningTick : _firstResponseTick).TotalMilliseconds,
            PostprocessDurationMs = (int)Stopwatch.GetElapsedTime(_endResponseTick, _finishTick).TotalMilliseconds,
            TotalDurationMs = (int)Stopwatch.GetElapsedTime(firstTick, _finishTick).TotalMilliseconds,
            InputTokens = _lastSegment.Usage.InputTokens,
            OutputTokens = _lastSegment.Usage.OutputTokens,
            ReasoningTokens = _lastSegment.Usage.ReasoningTokens,
            IsUsageReliable = _lastSegment.IsUsageReliable,
            InputCost = Cost.InputTokenPrice,
            OutputCost = Cost.OutputTokenPrice,
            ClientInfo = clientInfo,
        };

        byte transactionTypeId = (byte)(isApi ? DBTransactionType.ApiCost : DBTransactionType.Cost);
        if (Cost.CostBalance > 0)
        {
            usage.BalanceTransaction = new()
            {
                UserId = userId,
                CreatedAt = usage.CreatedAt,
                CreditUserId = userId,
                Amount = -Cost.CostBalance,
                TransactionTypeId = transactionTypeId,
            };
        }
        if (Cost.CostCount > 0 || Cost.CostTokens > 0)
        {
            usage.UsageTransaction = new()
            {
                UserModelId = _userModel.Id,
                CreditUserId = userId,
                CreatedAt = usage.CreatedAt,
                CountAmount = -Cost.CostCount,
                TokenAmount = -Cost.CostTokens,
                TransactionTypeId = transactionTypeId,
            };
        }

        return usage;
    }
}