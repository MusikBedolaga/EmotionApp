//
//  Errors.swift
//  EmotionsApp
//
//  Created by Муса Зарифянов on 08.11.2025.
//

import Foundation

enum AuthNetworkError: Error, LocalizedError {
    case invalidResponse
    case server(APIErrorPayload)
    case unauthorized
    case underlying(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse: return "Некорректный ответ сервера"
        case .server(let e): return e.message
        case .unauthorized: return "Неавторизовано"
        case .underlying(let e): return e.localizedDescription
        }
    }
}
