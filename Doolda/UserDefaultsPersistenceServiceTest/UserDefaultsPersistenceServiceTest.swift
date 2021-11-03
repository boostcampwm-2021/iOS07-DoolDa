//
//  UserDefaultsPersistenceServiceTest.swift
//  UserDefaultsPersistenceServiceTest
//
//  Created by 김민주 on 2021/11/03.
//

import XCTest

class UserDefaultsPersistenceServiceTest: XCTestCase {
    
    private var persistenceService: UserDefaultsPersistenceServiceProtocol?
    
    override func setUpWithError() throws {
        self.persistenceService = UserDefaultsPersistenceService()
    }

    override func tearDownWithError() throws {
        self.persistenceService = nil
    }

    func testSetValue() throws {
        guard let persistenceService = self.persistenceService else {
            XCTFail()
            return
        }
        persistenceService.set(key: "userId", value: "TestId")
        guard let userId: String = persistenceService.get(key: "userId") else {
            XCTFail()
            return
        }
        XCTAssertEqual(userId, "TestId")
    }
    
    func testRemoveValue() throws {
        guard let persistenceService = self.persistenceService else {
            XCTFail()
            return
        }
        persistenceService.remove(key: "userId")
        guard let userId: String? = persistenceService.get(key: "userId") else {
            XCTFail()
            return
        }
        XCTAssertNil(userId, "값이 지워지지 않았습니다.")
    }
}
