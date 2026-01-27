//
//  NoteClient.swift
//  EmotionsApp
//
//  Created by Муса Зарифянов on 14.11.2025.
//

import Foundation
import Alamofire

final class NoteClient: Client {
    private let secureStore: any SecureStore
    private let timeout = TimeInterval(30)
    private let notesBase: URL

    init(
        baseURL: URL,
        session: Session = .default,
        secureStore: any SecureStore
    ) {
        self.notesBase = baseURL.appendingPathComponent("api/notes")
        self.secureStore = secureStore
        super.init(baseURL: baseURL, session: session)
    }

    private func makeHeaders() async -> HTTPHeaders {
        let token = await secureStore.get("auth_token") ?? ""
        return [
//            "Authorization": "Bearer \(token)"
            "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJpZCI6NSwiZW1haWwiOiJpdmF2MTIzQGdtYWlsLmNvbSIsInVzZXJuYW1lIjoiSXZhbjEyMyIsInN1YiI6Ikl2YW4xMjMiLCJpYXQiOjE3NjM2NzI5MTcsImV4cCI6MTc2Mzc1OTMxN30.OIdoHY1EmRS3BwB_kCyM33D6jdgC0qVj_KRdULvREMo"
        ]
    }
    
    func createNote(_ req: NoteCreateDTO) async throws -> NoteResponseDTO {
        let url = notesBase.appendingPathComponent("create-note")
        let headers = await makeHeaders()
        return try await send(
            url, method: .post,
            headers: headers,
            body: req,
            timeout: timeout
        )
    }
    
    func getNote(_ id: Int64) async throws -> NoteResponseDTO {
        let url = notesBase.appendingPathComponent("\(id)")
        let headers = await makeHeaders()
        return try await send(
            url,
            method: .get,
            headers: headers,
            timeout: timeout
        )
    }
    
    func getAllNotes(album id: Int64,) async throws -> [NoteResponseDTO] {
        let url = notesBase.appendingPathComponent("\(id)")
        let headers = await makeHeaders()
        return try await send(
            url,
            method: .get,
            headers: headers,
            timeout: timeout
        )
    }
    
    func deleteNote(_ id: Int64) async throws {
        let url = notesBase.appendingPathComponent("album/\(id)")
        let headers = await makeHeaders()
        try await sendVoid(
            url,
            method: .delete,
            headers: headers,
            timeout: timeout
        )
    }
}
