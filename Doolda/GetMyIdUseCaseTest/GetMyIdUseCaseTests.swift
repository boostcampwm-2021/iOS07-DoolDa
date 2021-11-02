//
//  GetMyIdUseCaseTests.swift
//  DooldaTests
//
//  Created by 김민주 on 2021/11/02.
//

import XCTest
import Combine

class GetMyIdUseCaseTests: XCTestCase {
    private var dummyRepository: UserRepositoryProtocol?
    private var getMyIdUseCase: GetMyIdUseCase?

    override func tearDownWithError() throws {
        self.getMyIdUseCase = nil
        self.dummyRepository = nil
    }

    func testGetMyIdSuceess() throws {
        
        class DummyRepository: UserRepositoryProtocol {
            func fetchMyId() -> AnyPublisher<String, Error> {
                return Result.Publisher("00000000-0000-0000-0000-000000000001").eraseToAnyPublisher()
            }
            
            func fetchPairId() -> AnyPublisher<String, Error> {
                return Result.Publisher("DummyPairId").eraseToAnyPublisher()
            }
            
            func saveMyId(_ id: String) {}
            
            func savePairId(_ id: String) {}
            
            func getGlobalFont() -> String {
                return "font"
            }
        }
        
        self.dummyRepository = DummyRepository()
        if let repository = self.dummyRepository {
            self.getMyIdUseCase = GetMyIdUseCase(userRepository: repository)
        }
        
        guard let usecase = self.getMyIdUseCase else {
            XCTFail()
            return
        }
        usecase.getMyId().sink { completion in
            switch completion {
            case .finished:
                break
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        } receiveValue: { id in
            XCTAssertEqual("00000000-0000-0000-0000-000000000001", id, "전달되는 id 값이 예상 id값과 다릅니다.")
        }.cancel()
    }
    
    func testGetMyIdError() throws {
        enum DummyError: Error {
            case dummyError
        }
        
        class DummyRepository: UserRepositoryProtocol {
            func fetchMyId() -> AnyPublisher<String, Error> {
                return Result.Publisher(DummyError.dummyError).eraseToAnyPublisher()
            }
            
            func fetchPairId() -> AnyPublisher<String, Error> {
                return Result.Publisher("DummyPairId").eraseToAnyPublisher()
            }
            
            func saveMyId(_ id: String) {}
            
            func savePairId(_ id: String) {}
            
            func getGlobalFont() -> String {
                return "font"
            }
        }
        
        self.dummyRepository = DummyRepository()
        if let repository = self.dummyRepository {
            self.getMyIdUseCase = GetMyIdUseCase(userRepository: repository)
        }
        
        guard let usecase = self.getMyIdUseCase else {
            XCTFail()
            return
        }
        usecase.getMyId().sink { completion in
            switch completion {
            case .finished:
                break
            case .failure(let error):
                guard let dummyError = error as? DummyError else {
                    XCTFail("전달되는 error 값이 예상 error값과 다릅니다.")
                    return
                }
                XCTAssertEqual(DummyError.dummyError, dummyError, "전달되는 error 값이 예상 error값과 다릅니다.")
            }
        } receiveValue: { id in
            XCTFail()
        }.cancel()
    }
}
