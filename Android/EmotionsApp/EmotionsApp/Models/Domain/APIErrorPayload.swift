//
//  APIErrorPayload.swift
//  EmotionsApp
//
//  Created by Муса Зарифянов on 08.11.2025.
//

import Foundation

struct APIErrorPayload: Codable, Error {
    let message: String
    let code: String?
}
