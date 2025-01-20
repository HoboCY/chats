﻿using Chats.BE.Services.Models.Dtos;
using Chats.BE.Services.Models.Extensions;
using OpenAI.Chat;
using System.Runtime.CompilerServices;

namespace Chats.BE.Services.Models;

public abstract partial class ChatService
{
    public async IAsyncEnumerable<InternalChatSegment> ChatStreamedFEProcessed(IReadOnlyList<ChatMessage> messages, ChatCompletionOptions options, ChatExtraDetails feOptions, [EnumeratorCancellation] CancellationToken cancellationToken)
    {
        ChatMessage[] filteredMessage = await FEPreprocess(messages, options, feOptions, cancellationToken);

        await foreach (InternalChatSegment seg in ChatStreamedSimulated(suggestedStreaming: true, filteredMessage, options, cancellationToken))
        {
            yield return seg;
        }
    }

    public async IAsyncEnumerable<InternalChatSegment> ChatStreamedSimulated(bool suggestedStreaming, IReadOnlyList<ChatMessage> messages, ChatCompletionOptions options, [EnumeratorCancellation] CancellationToken cancellationToken)
    {
        // notify inputTokenCount first to better support price calculation
        int inputTokens = GetPromptTokenCount(messages);
        int outputTokens = 0;
        yield return InternalChatSegment.InputOnly(inputTokens);

        if (suggestedStreaming && Model.ModelReference.AllowStreaming)
        {
            await foreach (ChatSegment seg in ChatStreamed(messages, options, cancellationToken))
            {
                yield return seg.ToInternal(() => new Dtos.ChatTokenUsage
                {
                    InputTokens = inputTokens,
                    OutputTokens = outputTokens += Tokenizer.CountTokens(seg.TextSegment),
                    ReasoningTokens = 0
                });
            }
        }
        else
        {
            ChatSegment seg = await Chat(messages, options, cancellationToken);
            yield return seg.ToInternal(() => new Dtos.ChatTokenUsage()
            {
                InputTokens = inputTokens,
                OutputTokens = outputTokens += Tokenizer.CountTokens(seg.TextSegment),
                ReasoningTokens = 0
            });
        }
    }

    protected virtual async Task<ChatMessage[]> FEPreprocess(IReadOnlyList<ChatMessage> messages, ChatCompletionOptions options, ChatExtraDetails feOptions, CancellationToken cancellationToken)
    {
        if (!Model.ModelReference.AllowSystemPrompt)
        {
            // Remove system prompt
            messages = messages.Where(m => m is not SystemChatMessage).ToArray();
        }
        else
        {
            // system message transform
            SystemChatMessage? existingSystemPrompt = messages.OfType<SystemChatMessage>().FirstOrDefault();
            DateTime now = feOptions.Now;
            if (existingSystemPrompt is not null)
            {
                existingSystemPrompt.Content[0] = existingSystemPrompt.Content[0].Text
                    .Replace("{{CURRENT_DATE}}", now.ToString("yyyy/MM/dd"))
                    .Replace("{{MODEL_NAME}}", Model.ModelReference.ShortName ?? Model.ModelReference.Name)
                    .Replace("{{CURRENT_TIME}}", now.ToString("HH:mm:ss"));
                ;
            }
        }

        ChatMessage[] filteredMessage = await messages
            .ToAsyncEnumerable()
            .SelectAwait(async m => await FilterVision(Model.ModelReference.AllowVision, m, cancellationToken))
            .ToArrayAsync(cancellationToken);
        if (!Model.ModelReference.AllowSearch)
        {
            options.RemoveAllowSearch();
        }
        options.Temperature = Model.ModelReference.UnnormalizeTemperature(options.Temperature);

        return filteredMessage;
    }

    protected virtual bool SupportsVisionLink => true;

    protected virtual async Task<ChatMessage> FilterVision(bool allowVision, ChatMessage message, CancellationToken cancellationToken)
    {
        if (!allowVision)
        {
            return ReplaceUserMessageImageIntoLinkText(message);
        }
        else if (SupportsVisionLink)
        {
            return message;
        }
        else
        {
            return await DownloadVision(message, cancellationToken);
        }

        static ChatMessage ReplaceUserMessageImageIntoLinkText(ChatMessage message)
        {
            return message switch
            {
                UserChatMessage userChatMessage => new UserChatMessage(userChatMessage.Content.Select(c => c.Kind switch
                {
                    var x when x == ChatMessageContentPartKind.Image => ChatMessageContentPart.CreateTextPart(c.ImageUri.ToString()),
                    _ => c,
                })),
                _ => message,
            };
        }

        async Task<ChatMessage> DownloadVision(ChatMessage message, CancellationToken cancellationToken)
        {
            using HttpClient http = new();
            return message switch
            {
                UserChatMessage userChatMessage => new UserChatMessage(await userChatMessage.Content
                    .ToAsyncEnumerable()
                    .SelectAwait(async c => c switch
                    {
                        { Kind: ChatMessageContentPartKind.Image, ImageUri: not null }  => await DownloadImagePart(http, c.ImageUri, cancellationToken),
                        _ => c,
                    })
                    .ToArrayAsync(cancellationToken)),
                _ => message,
            };

            static async Task<ChatMessageContentPart> DownloadImagePart(HttpClient http, Uri url, CancellationToken cancellationToken)
            {
                HttpResponseMessage resp = await http.GetAsync(url, cancellationToken);
                if (!resp.IsSuccessStatusCode)
                {
                    throw new Exception($"Failed to download image from {url}");
                }

                string contentType = resp.Content.Headers.ContentType?.MediaType ?? "application/octet-stream";
                return ChatMessageContentPart.CreateImagePart(await BinaryData.FromStreamAsync(await resp.Content.ReadAsStreamAsync(cancellationToken), cancellationToken), contentType, null);
            }
        }
    }
}
