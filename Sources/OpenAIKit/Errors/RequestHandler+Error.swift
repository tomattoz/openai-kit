public enum RequestHandlerError: Error {
    case invalidURLGenerated
    case responseBodyMissing
    case errorParsingFailed(String)
}
