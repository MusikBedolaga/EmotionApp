import Foundation

protocol APIClientProtocol {
    func request<T: Decodable>(endpoint: Endpoint) async throws -> T
    func request(endpoint: Endpoint) async throws
}

final class APIClient {
    private let session: URLSession
    private let tokenManager: TokenManagerProtocol

    init(session: URLSession = .shared, tokenManager: TokenManagerProtocol) {
        self.session = session
        self.tokenManager = tokenManager
    }
}

// MARK: - APIClientProtocol
extension APIClient: APIClientProtocol {
    func request<T: Decodable>(endpoint: Endpoint) async throws -> T {
        let (data, _) = try await performRequest(endpoint: endpoint)
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            log("Ошибка декодирования ответа: \(error.localizedDescription)")
            throw NetworkError.decodingFailed(error)
        }
    }

    func request(endpoint: Endpoint) async throws {
        _ = try await performRequest(endpoint: endpoint)
    }
}

// MARK: - Helpers
private extension APIClient {
    func performRequest(endpoint: Endpoint) async throws -> (Data, URLResponse) {
        var currentToken: String?

        if endpoint.requiresAuth {
            currentToken = await tokenManager.ensureToken()
        }

        let urlRequest = try URLRequestBuilder.build(for: endpoint, with: currentToken)
        log("Отправка запроса: \(urlRequest.httpMethod ?? "N/A") \(urlRequest.url?.absoluteString ?? "N/A")")
        if let headers = urlRequest.allHTTPHeaderFields {
            log("Заголовки запроса: \(headers)")
        }
        if let httpBody = urlRequest.httpBody, let bodyString = String(data: httpBody, encoding: .utf8) {
            log("Тело запроса: \(bodyString)")
        }
        let (data, response) = try await self.session.data(for: urlRequest)

        log("Получен ответ: HTTP \((response as? HTTPURLResponse)?.statusCode ?? 0) для запроса \(urlRequest.url?.absoluteString ?? "N/A")")

        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode == 401 {
                if endpoint.requiresAuth {
                    let reauthorized = await tokenManager.reauthorize()
                    if reauthorized {
                        let retryUrlRequest = try URLRequestBuilder.build(for: endpoint, with: await tokenManager.ensureToken())
                        let (retryData, retryResponse) = try await self.session.data(for: retryUrlRequest)
                        if let retryHttpResponse = retryResponse as? HTTPURLResponse, retryHttpResponse.statusCode == 401 {
                            log("Ошибка: 401 Unauthorized. Очистка учетных данных.")
                            await tokenManager.clearCredentials()
                            throw NetworkError.unauthorized
                        }
                        return (retryData, retryResponse)
                    } else {
                        await tokenManager.clearCredentials()
                        throw NetworkError.unauthorized
                    }
                }
            } else if !(200..<300).contains(httpResponse.statusCode) {
                log("Ошибка запроса: HTTP \(httpResponse.statusCode) для запроса \(urlRequest.url?.absoluteString ?? "N/A")")
                throw NetworkError.requestFailed(statusCode: httpResponse.statusCode, data: data)
            }
        }
        return (data, response)
    }

    func log(_ message: String) {
        print("🌐 [Сетевой слой] \(message)")
    }
}
