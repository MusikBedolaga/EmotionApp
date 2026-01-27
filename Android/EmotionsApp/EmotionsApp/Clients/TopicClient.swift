//
//  TopicClient.swift
//  EmotionsApp
//
//  Created by Муса Зарифянов on 14.11.2025.
//

import Foundation
import Alamofire

final class TopicClient: Client {
    private let token: String
    private lazy var headers: HTTPHeaders = [
        "Authorization": "Bearer \(token)"
    ]
    
    private let timeout = TimeInterval(60)
    
    init(baseURL: URL, session: Session, token: String) {
        let tokenBase = baseURL.appendingPathComponent("api/topics")
        self.token = token
        super.init(baseURL: tokenBase, session: session)
    }
    
    func getAllTopics() async throws -> [TopicShortDTO] {
        let url = baseURL
        return try await send(url, method: .get, headers: headers, timeout: timeout)
    }
}

