import Foundation

public struct ChatStream: Sendable {
    public let id: String
    public let object: String
    public let created: Date
    public let model: String
    public let choices: [ChatStream.Choice]
    public let responseFormat: Chat.ResponseFormat?
    public let webSearchOptions: Chat.WebSearchOptions?
    public let conversationId: String?
    public let messageId: String?
}

extension ChatStream: Codable {}

extension ChatStream {
    public struct Choice: Sendable {
        public let index: Int
        public let finishReason: FinishReason?
        public let delta: ChatStream.Choice.Message
    }
}

extension ChatStream.Choice: Codable {}

extension ChatStream.Choice {
    public struct Message: Sendable {
        public let content: String?
        public let role: String?
    }
}

extension ChatStream.Choice.Message: Codable {}

