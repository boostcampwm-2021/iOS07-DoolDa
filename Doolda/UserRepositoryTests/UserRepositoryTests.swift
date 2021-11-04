//
//  UserRepositoryTests.swift
//  UserRepositoryTests
//
//  Created by 김민주 on 2021/11/04.
//

import XCTest

class UserRepositoryTest: XCTestCase {
    
    private var userRepository: UserRepositoryProtocol?
    private let userId = "00000000-0000-0000-0000-000000000000"
    
    override func setUpWithError() throws {
        let userRepository = UserRepository(persistenceService: UserDefaultsPersistenceService(),
                                            networkService: FirebaseNetworkService())
        self.userRepository = userRepository
    }

    override func tearDownWithError() throws {
        self.userRepository = nil
        let persistenceService = UserDefaultsPersistenceService()
        persistenceService.remove(key: UserRepository.userId)
    }
    
    func testFetchMyIdSuccess() throws {
        let persistenceService = UserDefaultsPersistenceService()
        persistenceService.set(key: UserRepository.userId, value: self.userId)
        
        guard let userRepository = userRepository else {
            XCTFail()
            return
        }
        
        userRepository.fetchMyId()
            .sink(receiveCompletion: { completion in
            guard case .failure(let error) = completion else { return }
                XCTFail(error.localizedDescription)
        }, receiveValue: { myId in
            XCTAssertEqual(myId, self.userId, "불러온 내 id값이 예상값과 일치하지 않습니다.")
        })
    }

    func testFetchMyIdFail() throws {
        guard let userRepository = userRepository else {
            XCTFail()
            return
        }
        
        userRepository.fetchMyId()
            .sink(receiveCompletion: { completion in
            guard case .failure(let error) = completion else { return }
                print(error)
        }, receiveValue: { myId in
            XCTFail()

        })
    }
    
    func testsaveMyId() throws {
        let expectation = XCTestExpectation()

        guard let userRepository = userRepository else {
            XCTFail()
            return
        }
        userRepository.saveMyId(self.userId).sink { completion in
            guard case .failure(let error) = completion else { return }
                XCTFail(error.localizedDescription)
        } receiveValue: { result in
            if !result {
                XCTFail()
            } else {
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 10)
    }
}
