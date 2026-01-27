import Foundation

protocol Endpoint {
    var baseURL: URL { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var body: Encodable? { get }
    var requiresAuth: Bool { get }
}

extension Endpoint {
    var baseURL: URL {
        Environment.baseURL
    }

    var headers: [String: String]? {
        nil
    }

    var body: Encodable? {
        nil
    }

    var requiresAuth: Bool {
        true
    }
}
