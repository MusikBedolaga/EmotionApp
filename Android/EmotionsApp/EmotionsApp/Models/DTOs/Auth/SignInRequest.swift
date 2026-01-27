//
//  SignInRequest.swift
//  EmotionsApp
//
//  Created by Муса Зарифянов on 08.11.2025.
//

import Foundation

struct SignInRequest: Codable, Sendable {
    private var username: String
    private var password: String
    
    init(username: String, password: String) {
        self.username = username
        self.password = password
    }
}
