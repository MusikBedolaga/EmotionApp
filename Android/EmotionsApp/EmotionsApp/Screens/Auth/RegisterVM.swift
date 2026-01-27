//
//  RegisterVM.swift
//  EmotionsApp
//
//  Created by Муса Зарифянов on 08.11.2025.
//

import Foundation

@MainActor
final class RegisterVM: ObservableObject {
    @Published var username: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var error: String? = nil
    @Published var loading = false
    
    private let authService: any AuthService
    
    init(authService: any AuthService) {
        self.authService = authService
    }
    
    func register() async {
        error = nil
        
        guard !username.trimmingCharacters(in: .whitespaces).isEmpty else {
            error = "Имя не может быть пустым"
            return
        }
        
        guard isValidEmail(email) else {
            error = "Введите корректный email"
            return
        }
        
        guard password.count >= 6 else {
            error = "Пароль должен быть минимум 6 символов"
            return
        }
        
        loading = true
        defer { loading = false }
        
        do {
            try await authService.register(
                username: username,
                email: email,
                password: password
            )
        } catch {
            self.error = "Ошибка регистрации: \(error.localizedDescription)"
        }
    }
    
    private func isValidEmail(_ text: String) -> Bool {
        let regex = #"^\S+@\S+\.\S+$"#
        return text.range(of: regex, options: .regularExpression) != nil
    }
}

