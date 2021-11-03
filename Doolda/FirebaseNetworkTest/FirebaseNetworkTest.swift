//
//  FirebaseNetworkTest.swift
//  FirebaseNetworkTest
//
//  Created by 김민주 on 2021/11/02.
//

import XCTest
import Combine

import FirebaseCore
import Firebase

class FirebaseNetworkTest: XCTestCase {

    private var networkService: FirebaseNetworkProtocol?
    

    override func setUpWithError() throws {
        self.networkService = FirebaseNetworkService()
    }

    override func tearDownWithError() throws {
        self.networkService = nil
    }

    func testgetDummyPairId() throws {
        guard let networkService = networkService else {
            XCTFail()
            return
        }
        
        let expectation = XCTestExpectation()
        let publisher = networkService.getDocument(path: "some_uuid_for_user", in: "user")
        
        let subscriber = publisher
            .sink { completion in
            switch completion {
            case .finished:
                expectation.fulfill()
                break
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        } receiveValue: { data in
            guard let user = User(data: data) else {
                XCTFail("초기화 에러")
                return
            }
            XCTAssertEqual("some_uuid_for_pair", user.pairId)
            print(user.pairId)
        }
        
        wait(for: [expectation], timeout: 10)
        subscriber.cancel()
    }
}
