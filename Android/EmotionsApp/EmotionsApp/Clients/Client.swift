//
//  Client.swift
//  EmotionsApp
//
//  Created by Муса Зарифянов on 13.11.2025.
//

import Foundation
@preconcurrency import Alamofire

class Client {
    var baseURL: URL
    var session: Session
    
    init(baseURL: URL, session: Session) {
        self.baseURL = baseURL
        self.session = session
    }
    
    // MARK: - Public Methods
    
    func send<Response: Decodable & Sendable>(
        _ url: URL,
        method: HTTPMethod = .get,
        headers: HTTPHeaders? = nil,
        timeout: TimeInterval? = nil
    ) async throws -> Response {
        let decoder = makeDecoder()
        
        print("[Client] ➡️ REQUEST: \(method.rawValue) \(url.absoluteString)")
        
        let request = session.request(
            url,
            method: method,
            headers: headers,
            requestModifier: { req in
                if let timeout { req.timeoutInterval = timeout }
            }
        )
        .validate()
        
        let response = await request.serializingData().response
        
        let data = response.data ?? Data()
        let statusCode = response.response?.statusCode
        
        if let obj = try? JSONSerialization.jsonObject(with: data),
           let pretty = try? JSONSerialization.data(withJSONObject: obj, options: [.prettyPrinted]),
           let str = String(data: pretty, encoding: .utf8) {
            print("[Client] ✅ RESPONSE: \(url.absoluteString)\n\(str)")
        } else if let str = String(data: data, encoding: .utf8) {
            print("[Client] ✅ RESPONSE: \(url.absoluteString)\n\(str)")
        } else {
            print("[Client] ✅ RESPONSE: \(url.absoluteString) <\(data.count) bytes>")
        }
        
        if let error = response.error {
            print("[Client] ❌ ERROR: \(method.rawValue) \(url.absoluteString)\n\(error)")
            
            if let af = error.asAFError {
                if af.responseCode == 401 {
                    throw AuthNetworkError.unauthorized
                }
                
                if let statusCode,
                   (400...599).contains(statusCode),
                   let payload = try? decoder.decode(APIErrorPayload.self, from: data) {
                    throw AuthNetworkError.server(payload)
                }
                
                throw AuthNetworkError.underlying(af)
            }
            
            throw AuthNetworkError.underlying(error)
        }
        
        return try decoder.decode(Response.self, from: data)
    }
    
    
    func send<Request: Encodable & Sendable, Response: Decodable & Sendable>(
        _ url: URL,
        method: HTTPMethod = .post,
        headers: HTTPHeaders? = nil,
        body: Request,
        timeout: TimeInterval? = nil
    ) async throws -> Response {
        
        if let encodedBody = try? JSONEncoder().encode(body),
           let jsonString = String(data: encodedBody, encoding: .utf8) {
            print("[Client] ➡️ REQUEST: \(method.rawValue) \(url.absoluteString)\nBODY:\n\(jsonString)")
        } else {
            print("[Client] ➡️ REQUEST: \(method.rawValue) \(url.absoluteString)\nBODY: <unencodable>")
        }
        
        let decoder = makeDecoder()
        
        let request = session.request(
            url,
            method: method,
            parameters: body,
            encoder: JSONParameterEncoder.default,
            headers: headers,
            requestModifier: { req in
                if let timeout { req.timeoutInterval = timeout }
            }
        )
        .validate()
        
        let response = await request.serializingData().response
        
        let data = response.data ?? Data()
        let statusCode = response.response?.statusCode
        
        if let obj = try? JSONSerialization.jsonObject(with: data),
           let pretty = try? JSONSerialization.data(withJSONObject: obj, options: [.prettyPrinted]),
           let str = String(data: pretty, encoding: .utf8) {
            print("[Client] ✅ RESPONSE: \(url.absoluteString)\n\(str)")
        } else if let str = String(data: data, encoding: .utf8) {
            print("[Client] ✅ RESPONSE: \(url.absoluteString)\n\(str)")
        } else {
            print("[Client] ✅ RESPONSE: \(url.absoluteString) <\(data.count) bytes>")
        }
        
        if let error = response.error {
            print("[Client] ❌ ERROR: \(method.rawValue) \(url.absoluteString)\n\(error)")
            
            if let af = error.asAFError {
                if af.responseCode == 401 {
                    throw AuthNetworkError.unauthorized
                }
                
                if let statusCode,
                   (400...599).contains(statusCode),
                   let payload = try? decoder.decode(APIErrorPayload.self, from: data) {
                    throw AuthNetworkError.server(payload)
                }
                
                throw AuthNetworkError.underlying(af)
            }
            
            throw AuthNetworkError.underlying(error)
        }
        
        return try decoder.decode(Response.self, from: data)
    }
    
    func sendVoid(
        _ url: URL,
        method: HTTPMethod,
        headers: HTTPHeaders? = nil,
        timeout: TimeInterval? = nil
    ) async throws {
        print("[Client] ➡️ REQUEST: \(method.rawValue) \(url.absoluteString)")
        
        let request = session.request(
            url,
            method: method,
            headers: headers,
            requestModifier: { req in
                if let timeout { req.timeoutInterval = timeout }
            }
        )
        .validate()
        
        let response = await request.serializingData().response
        
        let data = response.data ?? Data()
        let statusCode = response.response?.statusCode
        
        if let obj = try? JSONSerialization.jsonObject(with: data),
           let pretty = try? JSONSerialization.data(withJSONObject: obj, options: [.prettyPrinted]),
           let str = String(data: pretty, encoding: .utf8) {
            print("[Client] ✅ RESPONSE (void): \(url.absoluteString)\n\(str)")
        } else if data.isEmpty {
            print("[Client] ✅ RESPONSE (void): \(url.absoluteString) <no content>")
        } else if let str = String(data: data, encoding: .utf8) {
            print("[Client] ✅ RESPONSE (void): \(url.absoluteString)\n\(str)")
        } else {
            print("[Client] ✅ RESPONSE (void): \(url.absoluteString) <\(data.count) bytes>")
        }
        
        if let error = response.error {
            print("[Client] ❌ ERROR (void): \(method.rawValue) \(url.absoluteString)\n\(error)")
            
            if let af = error.asAFError {
                if af.responseCode == 401 {
                    throw AuthNetworkError.unauthorized
                }
                
                if let statusCode,
                   (400...599).contains(statusCode) {
                    let decoder = makeDecoder()
                    if let payload = try? decoder.decode(APIErrorPayload.self, from: data) {
                        throw AuthNetworkError.server(payload)
                    }
                    throw AuthNetworkError.invalidResponse
                }
                
                throw AuthNetworkError.underlying(af)
            }
            
            throw AuthNetworkError.underlying(error)
        }
    }
    
    // MARK: - Decoder with date strategy
    
    private func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        // Пример формата: 2025-11-20T21:16:08.972+00:00
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        
        decoder.dateDecodingStrategy = .formatted(formatter)
        return decoder
    }
}
