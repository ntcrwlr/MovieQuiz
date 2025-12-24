//
//  ArrayTests.swift
//  MovieQuiz
//
//  Created by Сергей Бушков on 15.12.2025.
//

import XCTest
@testable import MovieQuiz

class ArrayTests: XCTestCase {
    func testGetValuInRange() throws {
        let array = [1,1,2,3,5]
        let value = array[safe:2]
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 2)
        
    }
    func testGetValueOutOfRange() throws {
        let array = [1,1,2,3,5]
        let value = array[safe:20]
        XCTAssertNil(value)
    }
}
