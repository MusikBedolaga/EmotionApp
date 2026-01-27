//
//  AuthResponse.swift
//  EmotionsApp
//
//  Created by Муса Зарифянов on 08.11.2025.
//

import Foundation

struct AuthResponse: Decodable, Sendable {
    private(set) var token: String
    
    
    
    init(token: String) {
        self.token = token
    }
}
