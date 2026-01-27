//
//  SignUpRequest.swift
//  EmotionsApp
//
//  Created by Муса Зарифянов on 08.11.2025.
//

import Foundation

struct SignUpRequest: Codable, Sendable {
    private var username: String
    private var email: String
    private var password: String
    
    init(username: String, email: String, password: String) {
        self.username = username
        self.email = email
        self.password = password
    }
}
