﻿using Chats.BE.DB;
using Chats.BE.Services.Models.Extensions;
using OpenAI.Chat;

namespace Chats.BE.Services.Models.ChatServices.OpenAI;

public class SiliconFlowChatService(Model model) : OpenAIChatService(model, new Uri("https://api.siliconflow.cn/v1"))
{
    protected override Task<ChatMessage[]> FEPreprocess(IReadOnlyList<ChatMessage> messages, ChatCompletionOptions options, ChatExtraDetails feOptions, CancellationToken cancellationToken)
    {
        options.SetMaxTokens(Model.ModelReference.MaxResponseTokens); // https://api-docs.deepseek.com/zh-cn/quick_start/pricing default 4096 but max 8192
        return base.FEPreprocess(messages, options, feOptions, cancellationToken);
    }
}