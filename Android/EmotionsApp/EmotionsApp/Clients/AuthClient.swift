//
//  AuthClient.swift
//  EmotionsApp
//
//  Created by Муса Зарифянов on 08.11.2025.
//

@preconcurrency import Alamofire
import Foundation

final class AuthClient: Client, @unchecked Sendable {
    
    override init(baseURL: URL, session: Session = .default) {
        super.init(baseURL: baseURL, session: session)
    }
    
    func register(_ req: SignUpRequest) async throws -> AuthResponse {
        let url = baseURL.appendingPathComponent("auth/sign-up")
        return try await send(url, body: req, timeout: 10)
    }

    func signIn(_ req: SignInRequest) async throws -> AuthResponse {
        let url = baseURL.appendingPathComponent("auth/sign-in")
        return try await send(url, body: req, timeout: 10)
    }
}
