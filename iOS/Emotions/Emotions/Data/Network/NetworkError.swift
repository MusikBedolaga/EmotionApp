import Foundation

enum NetworkError: Error, Equatable {
    case invalidURL
    case requestFailed(statusCode: Int, data: Data?)
    case decodingFailed(Error)
    case encodingFailed(Error)
    case unauthorized
    case noCredentials
    case unknown(Error)

    static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL),
             (.unauthorized, .unauthorized),
             (.noCredentials, .noCredentials):
            return true
        case let (.requestFailed(statusCode: sc1, data: d1), .requestFailed(statusCode: sc2, data: d2)):
            return sc1 == sc2 && d1 == d2
        case (.decodingFailed, .decodingFailed),
             (.encodingFailed, .encodingFailed),
             (.unknown, .unknown):
            return true
        default:
            return false
        }
    }
}

