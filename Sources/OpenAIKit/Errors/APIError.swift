import Foundation

public struct APIError: Error, Codable {
    public let message: String
    public let type: String?
    public let param: String?
    public let code: String?
}

struct APIErrorResponse: Error, Codable {
    public let error: APIError
}

struct WebAPIErrorResponse: Error, Codable {
    public let detail: APIError
}

extension APIError: CustomStringConvertible {
    public var description: String {
        message
    }
}
