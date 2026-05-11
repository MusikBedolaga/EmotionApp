//
//  EmotionsTests.swift
//  EmotionsTests
//
//  Created by Муса Зарифянов on 30.12.2025.
//

import XCTest
@testable import Emotions

final class EmotionsTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testTopicEquatable() {
        let date = Date(timeIntervalSince1970: 0)
        let t1 = Topic(id: 1, name: "Работа", colorHex: "#112233", createdAt: date)
        let t2 = Topic(id: 1, name: "Работа", colorHex: "#112233", createdAt: date)
        XCTAssertEqual(t1, t2)
    }

    func testAlbumFields() {
        let a = Album(
            id: 10,
            userId: 99,
            title: "Дневник",
            description: "Описание",
            createdAt: Date(timeIntervalSince1970: 100)
        )
        XCTAssertEqual(a.id, 10)
        XCTAssertEqual(a.userId, 99)
        XCTAssertEqual(a.title, "Дневник")
        XCTAssertEqual(a.description, "Описание")
    }
}
