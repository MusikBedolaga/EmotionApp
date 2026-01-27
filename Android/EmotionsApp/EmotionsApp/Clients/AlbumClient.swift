//
//  ContentClient.swift
//  EmotionsApp
//
//  Created by Муса Зарифянов on 13.11.2025.
//

import Foundation
import Alamofire

final class AlbumClient: Client {

    private let secureStore: any SecureStore
    private let timeout = TimeInterval(30)
    private let albumsBase: URL

    init(
        baseURL: URL,
        session: Session = .default,
        secureStore: any SecureStore
    ) {
//        self.albumsBase = baseURL.appendingPathComponent("api/albums")
        self.albumsBase = URL(string: "http://localhost:50245")!.appendingPathComponent("api/albums")
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

    func createAlbum(_ req: AlbumCreateDTO) async throws -> AlbumResponseDTO {
        let url = albumsBase.appendingPathComponent("create-album")
        let headers = await makeHeaders()
        return try await send(
            url,
            method: .post,
            headers: headers,
            body: req,
            timeout: timeout
        )
    }

    func getAlbum(_ id: Int64) async throws -> AlbumResponseDTO {
        let url = albumsBase.appendingPathComponent("\(id)")
        let headers = await makeHeaders()
        return try await send(
            url,
            method: .get,
            headers: headers,
            timeout: timeout
        )
    }

    func updateAlbum(_ id: Int64, _ req: AlbumUpdateDTO) async throws -> AlbumResponseDTO {
        let url = albumsBase.appendingPathComponent("\(id)")
        let headers = await makeHeaders()
        return try await send(
            url,
            method: .patch,
            headers: headers,
            body: req,
            timeout: timeout
        )
    }

    func deleteAlbum(_ id: Int64) async throws {
        let url = albumsBase.appendingPathComponent("\(id)")
        let headers = await makeHeaders()
        try await sendVoid(
            url,
            method: .delete,
            headers: headers,
            timeout: timeout
        )
    }

    func getAllAlbums() async throws -> [AlbumResponseDTO] {
        let url = albumsBase.appendingPathComponent("all-albums")
        let headers = await makeHeaders()
        return try await send(
            url,
            method: .get,
            headers: headers,
            timeout: timeout
        )
    }

    func getAlbumsByTopic(_ topicId: Int64) async throws -> [AlbumShortDTO] {
        let url = albumsBase.appendingPathComponent("by-topic/\(topicId)")
        let headers = await makeHeaders()
        return try await send(
            url,
            method: .get,
            headers: headers,
            timeout: timeout
        )
    }
}
