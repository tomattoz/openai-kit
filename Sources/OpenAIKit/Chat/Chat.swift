import Foundation

/**
 Given a prompt, the model will return one or more predicted chat completions, and can also return the probabilities of alternative tokens at each position.
 */
public struct Chat {
    public let id: String
    public let object: String
    public let created: Date
    public let model: String
    public let choices: [Choice]
    public let usage: Usage
    public let responseFormat: ResponseFormat?
    public let webSearchOptions: WebSearchOptions?
    public let conversationId: String?
    public let messageId: String?
}

extension Chat: Codable {}

extension Chat {
    public struct Choice {
        public let index: Int
        public let message: Message
        public let finishReason: FinishReason?
    }
}

extension Chat.Choice: Codable {}

extension Chat {
    public enum Message {
        case system(content: String)
        case user(content: String)
        case assistant(content: String)
    }
}

extension Chat.Message: Codable {
    private enum CodingKeys: String, CodingKey {
        case role
        case content
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let role = try container.decode(String.self, forKey: .role)
        let content = try container.decode(String.self, forKey: .content)
        switch role {
        case "system":
            self = .system(content: content)
        case "user":
            self = .user(content: content)
        case "assistant":
            self = .assistant(content: content)
        default:
            throw DecodingError.dataCorruptedError(forKey: .role, in: container, debugDescription: "Invalid type")
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .system(let content):
            try container.encode("system", forKey: .role)
            try container.encode(content, forKey: .content)
        case .user(let content):
            try container.encode("user", forKey: .role)
            try container.encode(content, forKey: .content)
        case .assistant(let content):
            try container.encode("assistant", forKey: .role)
            try container.encode(content, forKey: .content)
        }
    }
}

extension Chat.Message {
    public var content: String {
        get {
            switch self {
            case .system(let content), .user(let content), .assistant(let content):
                return content
            }
        }
        set {
            switch self {
            case .system: self = .system(content: newValue)
            case .user: self = .user(content: newValue)
            case .assistant: self = .assistant(content: newValue)
            }
        }
    }
}

extension Chat {
    public enum ResponseFormat: Codable, Sendable {

        /// Enables JSON mode, which ensures the message the model generates is valid JSON. Note, if you want to
        /// supply your own schema use `jsonSchema` instead.
        ///
        /// Important: when using JSON mode, you must also instruct the model to produce JSON yourself via a
        /// system or user message. Without this, the model may generate an unending stream of whitespace until
        /// the generation reaches the token limit, resulting in a long-running and seemingly "stuck" request.
        /// Also note that the message content may be partially cut off if finish_reason="length", which indicates
        /// the generation exceeded max_tokens or the conversation exceeded the max context length.
        case jsonObject

        /// Enables Structured Outputs which ensures the model will match your supplied JSON schema.
        /// Learn more in the Structured Outputs guide: https://platform.openai.com/docs/guides/structured-outputs
        ///
        /// - Parameters:
        ///   - name: The name of the response format. Must be a-z, A-Z, 0-9, or contain underscores and dashes,
        ///           with a maximum length of 64.
        ///
        ///   - description: A description of what the response format is for, used by the model to determine how
        ///                  to respond in the format.
        ///
        ///   - schema: The schema for the response format, described as a JSON Schema object.
        ///
        ///   - strict: Whether to enable strict schema adherence when generating the output. If set to true, the
        ///             model will always follow the exact schema defined in the schema field. Only a subset of JSON Schema
        ///             is supported when strict is true. To learn more, read the Structured Outputs guide.
        case jsonSchema(
            name: String,
            description: String? = nil,
            schema: [String: AIProxyJSONValue]? = nil,
            strict: Bool? = nil
        )

        /// Instructs the model to produce text only.
        case text

        private enum RootKey: String, CodingKey {
            case type
            case jsonSchema = "json_schema"
        }

        private enum SchemaKey: String, CodingKey {
            case description
            case name
            case schema
            case strict
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: RootKey.self)
            switch self {
            case .jsonObject:
                try container.encode("json_object", forKey: .type)
            case .jsonSchema(
                name: let name,
                description: let description,
                schema: let schema,
                strict: let strict
            ):
                try container.encode("json_schema", forKey: .type)
                var nestedContainer = container.nestedContainer(
                    keyedBy: SchemaKey.self,
                    forKey: .jsonSchema
                )
                try nestedContainer.encode(name, forKey: .name)
                try nestedContainer.encodeIfPresent(description, forKey: .description)
                try nestedContainer.encodeIfPresent(schema, forKey: .schema)
                try nestedContainer.encodeIfPresent(strict, forKey: .strict)
            case .text:
                try container.encode("text", forKey: .type)
            }
        }
    }
}

extension Chat {
    public struct WebSearchOptions: Codable, Sendable {
        
        public enum SearchContextSize: String, Codable, Sendable {
            case low
            case medium
            case high
        }
        
        public struct UserLocation: Codable, Sendable {
            
            public struct Approximate: Codable, Sendable {
                let city: String?
                let country: String?
                let region: String?
                let timezone: String?
                let type: String?
                
                public init(
                    city: String? = nil,
                    country: String? = nil,
                    region: String? = nil,
                    timezone: String? = nil,
                    type: String? = "approximate"
                ) {
                    self.city = city
                    self.country = country
                    self.region = region
                    self.timezone = timezone
                    self.type = type
                }
            }
            
            let approximate: Approximate
            
            public init(approximate: Approximate) {
                self.approximate = approximate
            }
        }
        
        let searchContextSize: SearchContextSize?
        let userLocation: UserLocation?
        
        private enum CodingKeys: String, CodingKey {
            case searchContextSize = "search_context_size"
            case userLocation = "user_location"
        }
        
        public init(
            searchContextSize: SearchContextSize?,
            userLocation: UserLocation?
        ) {
            self.searchContextSize = searchContextSize
            self.userLocation = userLocation
        }
    }

}
