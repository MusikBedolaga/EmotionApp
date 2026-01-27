//
//  AuthVM.swift
//  EmotionsApp
//
//  Created by Муса Зарифянов on 08.11.2025.
//

import Foundation

@MainActor
final class AuthVM: ObservableObject {
    @Published var username: String = ""
    @Published var password: String = ""
    @Published var error: String? = nil
    @Published var loading = false
    
    private var authService: any AuthService
    
    init(authService: any AuthService) {
        self.authService = authService
    }
    
    public func authorization() async {
        error = nil
        
        guard !username.trimmingCharacters(in: .whitespaces).isEmpty else {
            error = "Имя не может быть пустым"
            return
        }
        
        guard password.count >= 6 else {
            error = "Пароль должен быть минимум 6 символов"
            return
        }
        
        loading = true
        defer { loading = false }
        
        do {
            try await authService.signIn(username: username, password: password)
        } catch {
            self.error = "Ошибка входа: \(error.localizedDescription)"
        }
    }
}
