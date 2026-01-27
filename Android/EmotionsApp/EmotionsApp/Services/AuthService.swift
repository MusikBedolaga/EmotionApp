//
//  AuthService.swift
//  EmotionsApp
//
//  Created by Муса Зарифянов on 08.11.2025.
//

import Foundation
import SwiftUI

protocol AuthService: Sendable {
    func register(
        username: String,
        email: String,
        password: String
    ) async throws
    
    func signIn(username: String, password: String) async throws
    
}

actor AuthServiceImpl: AuthService {
    private let client: AuthClient
    private let secureStore: any SecureStore
    
    static let shared = AuthServiceImpl(
        client: AuthClient(baseURL: Bundle.main.serverBaseURL),
        secureStore: KeychainStore()
    )
    
    init(client: AuthClient = AuthClient(baseURL: Bundle.main.serverBaseURL),
         secureStore: any SecureStore) {
        self.client = client
        self.secureStore = secureStore
    }
    
    func register(username: String, email: String, password: String) async throws {
        var request = SignUpRequest(
            username: username,
            email: email,
            password: password
        )
        
        let token = try await client.register(request).token
        
        await secureStore.set(username, for: "username")
        await secureStore.set(password, for: "password")
        await secureStore.set(token, for: "auth_token")
    }
    
    func signIn(username: String, password: String) async throws {
        var request = SignInRequest(
            username: username,
            password: password
        )
        
        let token = try await client.signIn(request).token
        
        await secureStore.set(token, for: "auth_token")
    }
}

struct AuthServiceKey: EnvironmentKey {
    static let defaultValue: any AuthService = AuthServiceImpl(
        client: AuthClient(baseURL: Bundle.main.serverBaseURL),
        secureStore: KeychainStore()
    )
}
