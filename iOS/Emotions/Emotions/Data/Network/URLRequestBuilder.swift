import Foundation

struct URLRequestBuilder {
    static func build(for endpoint: Endpoint, with token: String?) throws -> URLRequest {
        let url = endpoint.baseURL.appendingPathComponent(endpoint.path)

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue

        endpoint.headers?.forEach { key, value in
            request.addValue(value, forHTTPHeaderField: key)
        }

        if endpoint.requiresAuth, let token = token {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body = endpoint.body {
            do {
                request.httpBody = try JSONEncoder().encode(body)
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            } catch {
                throw NetworkError.encodingFailed(error)
            }
        }

        return request
    }
}
