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

    func testSetKey() throws {
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
}
