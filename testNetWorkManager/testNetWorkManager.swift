//
//  testNetWorkManager.swift
//  testNetWorkManager
//
//  Created by yklin on 2024/5/26.
//

import XCTest
@testable import MyBusMapSwiftUI

final class TestNetWorkManager: XCTestCase {
    let sut = NetworkManager.stub
    
    func testFetchToken() async throws {
        let token = try await sut.fetchToken()
        XCTAssertNotEqual(token.count, 0)
    }

}
