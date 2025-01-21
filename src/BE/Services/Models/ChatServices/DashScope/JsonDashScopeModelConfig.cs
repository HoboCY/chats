﻿using System.Text.Json.Serialization;

namespace Chats.BE.Services.Models.ChatServices.DashScope;

public record JsonDashScopeModelConfig
{
    [JsonPropertyName("prompt")]
    public required string Prompt { get; init; }

    [JsonPropertyName("temperature")]
    public required float Temperature { get; init; }

    [JsonPropertyName("version")]
    public required string ModelName { get; init; }

    [JsonPropertyName("enableSearch")]
    public bool? EnableSearch { get; init; }
}
