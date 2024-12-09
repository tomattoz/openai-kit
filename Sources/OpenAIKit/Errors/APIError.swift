import Foundation

public struct APIError: Error, Codable {
    public let message: String
    public let type: String?
    public let param: String?
    public let code: String?
}

struct APIErrorResponse: Codable {
    public let error: APIError
}

struct WebAPIErrorResponse: Codable {
    public let detail: APIError
}

struct WebAPIErrorStringResponse: Codable {
    public let detail: String
}

extension APIError: CustomStringConvertible {
    public var description: String {
        message
    }
}

extension JSONDecoder {
    func decodeAPIError(_ data: Data) throws -> APIError {
        var error: APIError?
        
        if error == nil {
            do {
                error = try JSONDecoder().decode(WebAPIErrorResponse.self, from: data).detail
            } catch {}
        }

        if error == nil {
            do {
                let string = try JSONDecoder().decode(WebAPIErrorStringResponse.self, from: data).detail
                
                if string == "cf_chl_opt" {
                    error = .init(message: "DDoS protection. Please try again later.",
                                  type: nil,
                                  param: nil,
                                  code: "cf_chl_opt")
                }
                else {
                    error = .init(message: string, type: nil, param: nil, code: string)
                }
            } catch {}
        }

        if error == nil {
            do {
                error = try JSONDecoder().decode(APIErrorResponse.self, from: data).error
            } catch {}
        }
        
        if let error {
            return error
        }
        else {
            throw RequestHandlerError.errorParsingFailed(
                .init(data: data, encoding: .utf8) ?? "data \(data.count)")
        }
    }
}
