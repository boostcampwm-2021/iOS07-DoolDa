//
//  FirebaseNetworkTest.swift
//  FirebaseNetworkTest
//
//  Created by 김민주 on 2021/11/02.
//

import Combine
import XCTest

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

    func testGetDummyPairId() throws {
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
    
    func testGetDummyRecentlyEditedUser() throws {
        guard let networkService = networkService else {
            XCTFail()
            return
        }
        
        let expectation = XCTestExpectation()
        let publisher = networkService.getDocument(path: "some_uuid_for_pair", in: "pair")
        
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
            guard let pair = Pair(data: data) else {
                XCTFail("초기화 에러")
                return
            }
            XCTAssertEqual("some_uuid_for_user", pair.recentlyEditedUser)
        }
        
        wait(for: [expectation], timeout: 10)
        subscriber.cancel()
    }
    
    func testSetUserDocument() throws {
        guard let networkService = networkService else {
            XCTFail()
            return
        }
        
        let expectation = XCTestExpectation()
        let publisher = networkService.setDocument(
            path: UUID().uuidString,
            in:"user",
            with: ["pairId": ""])
        
        let subscriber = publisher
            .sink { completion in
            switch completion {
            case .finished:
                expectation.fulfill()
                break
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        } receiveValue: { result in
            XCTAssertTrue(result, "결과 값이 true가 아닙니다.")
        }
        
        wait(for: [expectation], timeout: 10)
        subscriber.cancel()
    }
    
    func testSetPageDocument() throws {
        guard let networkService = networkService else {
            XCTFail()
            return
        }
        
        let expectation = XCTestExpectation()
        let publisher = networkService.setDocument(
            path: nil,
            in: "page",
            with: [
                "author": "",
                "createdTime": Date(),
                "jsonPath": "",
                "pairId":"",
            ]
        )
        
        let subscriber = publisher
            .sink { completion in
            switch completion {
            case .finished:
                expectation.fulfill()
                break
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        } receiveValue: { result in
            XCTAssertTrue(result, "결과 값이 true가 아닙니다.")
        }
        
        wait(for: [expectation], timeout: 10)
        subscriber.cancel()
    }
}
