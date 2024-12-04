import Foundation

public struct APIError: Error, Codable {
    public let message: String
    public let type: String
    public let param: String?
    public let code: String?
}

public struct APIErrorResponse: Error, Codable {
    public let error: APIError
}


