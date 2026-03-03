import AsyncHTTPClient
import NIOHTTP1
import Foundation

struct CreateChatRequest: Request {
    let method: HTTPMethod = .POST
    let path = "/v1/chat/completions"
    let body: Data?
    
    init(
        model: String,
        messages: [Chat.Message],
        temperature: Double?,
        topP: Double?,
        n: Int?,
        stream: Bool?,
        stops: [String]?,
        maxTokens: Int?,
        presencePenalty: Double?,
        frequencyPenalty: Double?,
        logitBias: [String: Int]?,
        user: String?,
        responseFormat: Chat.ResponseFormat?,
        webSearchOptions: Chat.WebSearchOptions? = nil,
        parentMessageID: String?,
        conversationID: String?,
        promptCacheRetention: String?,
        promptCacheKey: String?
    ) throws {
        
        let body = Body(
            model: model,
            messages: messages,
            temperature: temperature,
            topP: topP,
            n: n,
            stream: stream,
            stops: stops,
            maxTokens: maxTokens,
            presencePenalty: presencePenalty,
            frequencyPenalty: frequencyPenalty,
            logitBias: logitBias,
            user: user,
            responseFormat: responseFormat,
            webSearchOptions: webSearchOptions,
            parentMessageID: parentMessageID,
            conversationID: conversationID,
            promptCacheRetention: promptCacheRetention,
            promptCacheKey: promptCacheKey
        )
                
        self.body = try Self.encoder.encode(body)
    }
}

extension CreateChatRequest {
    struct Body: Encodable {
        let model: String
        let messages: [Chat.Message]
        let temperature: Double?
        let topP: Double?
        let n: Int?
        let stream: Bool?
        let streamOptions = ["include_usage": true]
        let stops: [String]?
        let maxTokens: Int?
        let presencePenalty: Double?
        let frequencyPenalty: Double?
        let logitBias: [String: Int]?
        let user: String?
        let responseFormat: Chat.ResponseFormat?
        let webSearchOptions: Chat.WebSearchOptions?
        let parentMessageID: String?
        let conversationID: String?
        let promptCacheRetention: String?
        let promptCacheKey: String?

        enum CodingKeys: String, CodingKey {
            case model
            case messages
            case temperature
            case topP
            case n
            case stream
            case streamOptions
            case stop
            case maxTokens
            case presencePenalty
            case frequencyPenalty
            case logitBias
            case user
            case responseFormat
            case webSearchOptions
            case parentMessageID
            case conversationID
            case promptCacheRetention
            case promptCacheKey
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(model, forKey: .model)
            
            try container.encodeIfPresent(temperature, forKey: .temperature)
            try container.encodeIfPresent(topP, forKey: .topP)
            try container.encodeIfPresent(n, forKey: .n)
            try container.encodeIfPresent(stream, forKey: .stream)
            if stream == true {
                try container.encodeIfPresent(streamOptions, forKey: .streamOptions)
            }
            try container.encodeIfPresent(maxTokens, forKey: .maxTokens)
            try container.encodeIfPresent(presencePenalty, forKey: .presencePenalty)
            try container.encodeIfPresent(frequencyPenalty, forKey: .frequencyPenalty)
            try container.encodeIfPresent(user, forKey: .user)
            try container.encodeIfPresent(responseFormat, forKey: .responseFormat)
            try container.encodeIfPresent(webSearchOptions, forKey: .webSearchOptions)
            try container.encodeIfPresent(parentMessageID, forKey: .parentMessageID)
            try container.encodeIfPresent(promptCacheRetention, forKey: .promptCacheRetention)
            try container.encodeIfPresent(promptCacheKey, forKey: .promptCacheKey)

            if !messages.isEmpty {
                try container.encode(messages, forKey: .messages)
            }

            if let stops, !stops.isEmpty {
                try container.encodeIfPresent(stops, forKey: .stop)
            }

            if let logitBias, !logitBias.isEmpty {
                try container.encode(logitBias, forKey: .logitBias)
            }
        }
    }
}
