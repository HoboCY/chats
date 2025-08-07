﻿using Chats.BE.DB;
using Chats.BE.Services.Models.Extensions;
using OpenAI.Chat;

namespace Chats.BE.Services.Models.ChatServices.OpenAI;

public class XunfeiChatService(Model model) : ChatCompletionService(model, new Uri("https://spark-api-open.xf-yun.com/v1"))
{
    protected override void SetWebSearchEnabled(ChatCompletionOptions options, bool enabled)
    {
        options.GetOrCreateSerializedAdditionalRawData()["tools"] = BinaryData.FromObjectAsJson(new[]
        {
            new
            {
                type = "web_search",
                web_search = new
                {
                    enable = enabled,
                    show_ref_label = false,
                }
            }
        });
    }
}
