//
//  UserRepositoryTests.swift
//  UserRepositoryTests
//
//  Created by 김민주 on 2021/11/04.
//

import Combine
import XCTest

class UserRepositoryTest: XCTestCase {
    
    private let dummyUserId = "00000000-0000-0000-0000-000000000000"
    private let dummyfriendId = "00000000-0000-0000-0000-000000000001"
    private let dummyPairId = "00000000-0000-0000-0000-000000000002"
    private let dummyNotExistId = "00000000-0000-0000-0000-000000000005"
    
    private var userRepository: UserRepositoryProtocol?
    private var cancellables: Set<AnyCancellable> = []
    
    override func setUpWithError() throws {
        let userRepository = UserRepository(persistenceService: UserDefaultsPersistenceService(),
                                            networkService: FirebaseNetworkService())
        self.userRepository = userRepository
    }
    
    override func tearDownWithError() throws {
        self.userRepository = nil
        self.cancellables.removeAll()
        let persistenceService = UserDefaultsPersistenceService()
        persistenceService.remove(key: UserDefaults.Keys.userId)
    }
    
    func testFetchMyIdSuccess() throws {
        let persistenceService = UserDefaultsPersistenceService()
        persistenceService.set(key: UserDefaults.Keys.userId, value: self.dummyUserId)
        
        guard let userRepository = userRepository else {
            XCTFail()
            return
        }
        userRepository.fetchMyId()
            .sink(receiveCompletion: { completion in
                guard case .failure(let error) = completion else { return }
                XCTFail(error.localizedDescription)
            }, receiveValue: { myId in
                XCTAssertEqual(myId, self.dummyUserId, "불러온 내 id값이 예상값과 일치하지 않습니다.")
            }).store(in: &self.cancellables)
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
            }).store(in: &self.cancellables)
    }
    
    func testsaveMyId() throws {
        let expectation = XCTestExpectation()
        
        guard let userRepository = userRepository else {
            XCTFail()
            return
        }
        userRepository.saveMyId(self.dummyUserId).sink { completion in
            guard case .failure(let error) = completion else { return }
            XCTFail(error.localizedDescription)
        } receiveValue: { myId in
            XCTAssertEqual(myId, self.dummyUserId, "불러온 내 id값이 예상값과 일치하지 않습니다." )
            expectation.fulfill()
        }.store(in: &self.cancellables)
        wait(for: [expectation], timeout: 10)
    }
    
    func testSavePairId() throws {
        let expectation = XCTestExpectation()
        
        guard let userRepository = userRepository else {
            XCTFail()
            return
        }
        userRepository.savePairId(myId: self.dummyUserId,
                                  friendId: self.dummyfriendId,
                                  pairId: self.dummyPairId)
            .sink { completion in
                guard case .failure(let error) = completion else { return }
                XCTFail(error.localizedDescription)
            } receiveValue: { pairId in
                XCTAssertEqual(pairId, self.dummyPairId, "불러온 pair id값이 예상값과 일치하지 않습니다." )
                expectation.fulfill()
            }.store(in: &self.cancellables)
        wait(for: [expectation], timeout: 10)
    }
    
    func testCheckUserIdIsExistTrue() throws {
        let expectation = XCTestExpectation()
        
        guard let userRepository = userRepository else {
            XCTFail()
            return
        }
        userRepository.checkUserIdIsExist(self.dummyUserId)
            .sink { completion in
                guard case .failure(let error) = completion else { return }
                XCTFail(error.localizedDescription)
            } receiveValue: { result in
                XCTAssertTrue(result, "userId가 없습니다.")
                expectation.fulfill()
            }.store(in: &self.cancellables)
        wait(for: [expectation], timeout: 10)
    }
    
    func testCheckUserIdIsExistFalse() throws {
        let expectation = XCTestExpectation()
        
        guard let userRepository = userRepository else {
            XCTFail()
            return
        }
        userRepository.checkUserIdIsExist(self.dummyNotExistId)
            .sink { completion in
                guard case .failure(let error) = completion else { return }
                XCTFail(error.localizedDescription)
            } receiveValue: { result in
                XCTAssertFalse(result, "userId가 있습니다..")
                expectation.fulfill()
            }.store(in: &self.cancellables)
        
        wait(for: [expectation], timeout: 10)
    }
}
