//
//  EditPageUseCaseTest.swift
//  EditPageUseCaseTest
//
//  Created by Seunghun Yang on 2021/11/10.
//

import Combine
import XCTest

class EditPageUseCaseTest: XCTestCase {
    private var cancellables: Set<AnyCancellable> = []

    override func tearDown() {
        self.cancellables = []
    }
    
    enum TestError: Error {
        case notImplemented
        case failed
    }

    class DummyImageUseCase: ImageUseCaseProtocol {
        var isSuccessMode: Bool = true
        
        init(isSuccessMode: Bool) {
            self.isSuccessMode = isSuccessMode
        }
        
        func saveLocal(image: CIImage) -> AnyPublisher<URL, Never> {
            return Just(URL(string: "https://naver.com")!).eraseToAnyPublisher()
        }
        
        func saveRemote(for user: User, localUrl: URL) -> AnyPublisher<URL, Error> {
            if isSuccessMode {
                return Just(URL(string: "https://youtube.com")!).setFailureType(to: Error.self)
                    .delay(for: .seconds(1), tolerance: nil, scheduler: RunLoop.main, options: nil)
                    .eraseToAnyPublisher()
            } else {
                return Fail(error: TestError.failed).eraseToAnyPublisher()
            }
        }
    }
    
    class DummyPageRepository: PageRepositoryProtocol {
        var isSuccessMode: Bool = true
        
        init(isSuccessMode: Bool) {
            self.isSuccessMode = isSuccessMode
        }
        
        func savePage(_ page: PageEntity) -> AnyPublisher<PageEntity, Error> {
            if isSuccessMode {
                return Just(page)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            } else {
                return Fail(error: TestError.failed).eraseToAnyPublisher()
            }
        }
        
        func fetchPages(for pair: DDID) -> AnyPublisher<[PageEntity], Error> {
            return Fail(error: TestError.notImplemented).eraseToAnyPublisher()
        }
    }
    
    class DummyRawPageRepository: RawPageRepositoryProtocol {
        var isSuccessMode: Bool = true
        
        init(isSuccessMode: Bool) {
            self.isSuccessMode = isSuccessMode
        }
        
        
        func saveRawPage(_ rawPage: RawPageEntity) -> AnyPublisher<RawPageEntity, Error> {
            if isSuccessMode {
                return Just(rawPage)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            } else {
                return Fail(error: TestError.failed).eraseToAnyPublisher()
            }
        }
        
        func fetchRawPage(for path: String) -> AnyPublisher<RawPageEntity, Error> {
            return Fail(error: TestError.notImplemented).eraseToAnyPublisher()
        }
    }
    
    func testSavingSuccess() {
        let editPageUseCase = EditPageUseCase(
            imageUseCase: DummyImageUseCase(isSuccessMode: true),
            pageRepository: DummyPageRepository(isSuccessMode: true),
            rawPageRepository: DummyRawPageRepository(isSuccessMode: true)
        )
        
        let expectation = self.expectation(description: "testGetMyIdSuceess")

        editPageUseCase.addComponent(PhotoComponentEntity(frame: .zero, scale: .zero, angle: 0, aspectRatio: 0, imageUrl: URL(string: "https://naver.com")!))
        editPageUseCase.addComponent(PhotoComponentEntity(frame: .zero, scale: .zero, angle: 0, aspectRatio: 0, imageUrl: URL(string: "https://naver.com")!))
        editPageUseCase.addComponent(PhotoComponentEntity(frame: .zero, scale: .zero, angle: 0, aspectRatio: 0, imageUrl: URL(string: "https://naver.com")!))
        editPageUseCase.addComponent(PhotoComponentEntity(frame: .zero, scale: .zero, angle: 0, aspectRatio: 0, imageUrl: URL(string: "https://naver.com")!))
        editPageUseCase.addComponent(PhotoComponentEntity(frame: .zero, scale: .zero, angle: 0, aspectRatio: 0, imageUrl: URL(string: "https://naver.com")!))
        editPageUseCase.savePage(author: User(id: DDID(), pairId: DDID()))
    
        var error: Error?
        var result: Void?
    
        editPageUseCase.errorPublisher
            .compactMap { $0 }
            .sink { encounteredError in
                error = encounteredError
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        editPageUseCase.resultPublisher
            .compactMap { $0 }
            .sink { encounteredResult in
                result = encounteredResult
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 5)
        
        XCTAssertNil(error)
        XCTAssertNotNil(result)
    }
    
    func testSavingFailureDueToImageUseCase() {
        let editPageUseCase = EditPageUseCase(
            imageUseCase: DummyImageUseCase(isSuccessMode: false),
            pageRepository: DummyPageRepository(isSuccessMode: true),
            rawPageRepository: DummyRawPageRepository(isSuccessMode: true)
        )
        
        let expectation = self.expectation(description: "testSavingFailureDueToImageUseCase")

        editPageUseCase.addComponent(PhotoComponentEntity(frame: .zero, scale: .zero, angle: 0, aspectRatio: 0, imageUrl: URL(string: "https://naver.com")!))
        editPageUseCase.addComponent(PhotoComponentEntity(frame: .zero, scale: .zero, angle: 0, aspectRatio: 0, imageUrl: URL(string: "https://naver.com")!))
        editPageUseCase.addComponent(PhotoComponentEntity(frame: .zero, scale: .zero, angle: 0, aspectRatio: 0, imageUrl: URL(string: "https://naver.com")!))
        editPageUseCase.addComponent(PhotoComponentEntity(frame: .zero, scale: .zero, angle: 0, aspectRatio: 0, imageUrl: URL(string: "https://naver.com")!))
        editPageUseCase.addComponent(PhotoComponentEntity(frame: .zero, scale: .zero, angle: 0, aspectRatio: 0, imageUrl: URL(string: "https://naver.com")!))
        editPageUseCase.savePage(author: User(id: DDID(), pairId: DDID()))
    
        var error: Error?
        var result: Void?
    
        editPageUseCase.errorPublisher
            .compactMap { $0 }
            .sink { encounteredError in
                error = encounteredError
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        editPageUseCase.resultPublisher
            .compactMap { $0 }
            .sink { encounteredResult in
                result = encounteredResult
            }
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 5)
        
        XCTAssertNotNil(error)
        XCTAssertNil(result)
    }
    
    func testSavingFailureDueToPageRepository() {
        let editPageUseCase = EditPageUseCase(
            imageUseCase: DummyImageUseCase(isSuccessMode: true),
            pageRepository: DummyPageRepository(isSuccessMode: false),
            rawPageRepository: DummyRawPageRepository(isSuccessMode: true)
        )
        
        let expectation = self.expectation(description: "testSavingFailureDueToPageRepository")

        editPageUseCase.addComponent(PhotoComponentEntity(frame: .zero, scale: .zero, angle: 0, aspectRatio: 0, imageUrl: URL(string: "https://naver.com")!))
        editPageUseCase.addComponent(PhotoComponentEntity(frame: .zero, scale: .zero, angle: 0, aspectRatio: 0, imageUrl: URL(string: "https://naver.com")!))
        editPageUseCase.addComponent(PhotoComponentEntity(frame: .zero, scale: .zero, angle: 0, aspectRatio: 0, imageUrl: URL(string: "https://naver.com")!))
        editPageUseCase.addComponent(PhotoComponentEntity(frame: .zero, scale: .zero, angle: 0, aspectRatio: 0, imageUrl: URL(string: "https://naver.com")!))
        editPageUseCase.addComponent(PhotoComponentEntity(frame: .zero, scale: .zero, angle: 0, aspectRatio: 0, imageUrl: URL(string: "https://naver.com")!))
        editPageUseCase.savePage(author: User(id: DDID(), pairId: DDID()))
    
        var error: Error?
        var result: Void?
    
        editPageUseCase.errorPublisher
            .compactMap { $0 }
            .sink { encounteredError in
                error = encounteredError
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        editPageUseCase.resultPublisher
            .compactMap { $0 }
            .sink { encounteredResult in
                result = encounteredResult
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 5)
        
        XCTAssertNotNil(error)
        XCTAssertNil(result)
    }
    
    func testSavingFailureDueToRawPageRepository() {
        let editPageUseCase = EditPageUseCase(
            imageUseCase: DummyImageUseCase(isSuccessMode: true),
            pageRepository: DummyPageRepository(isSuccessMode: true),
            rawPageRepository: DummyRawPageRepository(isSuccessMode: false)
        )
        
        let expectation = self.expectation(description: "testSavingFailureDueToRawPageRepository")

        editPageUseCase.addComponent(PhotoComponentEntity(frame: .zero, scale: .zero, angle: 0, aspectRatio: 0, imageUrl: URL(string: "https://naver.com")!))
        editPageUseCase.addComponent(PhotoComponentEntity(frame: .zero, scale: .zero, angle: 0, aspectRatio: 0, imageUrl: URL(string: "https://naver.com")!))
        editPageUseCase.addComponent(PhotoComponentEntity(frame: .zero, scale: .zero, angle: 0, aspectRatio: 0, imageUrl: URL(string: "https://naver.com")!))
        editPageUseCase.addComponent(PhotoComponentEntity(frame: .zero, scale: .zero, angle: 0, aspectRatio: 0, imageUrl: URL(string: "https://naver.com")!))
        editPageUseCase.addComponent(PhotoComponentEntity(frame: .zero, scale: .zero, angle: 0, aspectRatio: 0, imageUrl: URL(string: "https://naver.com")!))
        editPageUseCase.savePage(author: User(id: DDID(), pairId: DDID()))
    
        var error: Error?
        var result: Void?
    
        editPageUseCase.errorPublisher
            .compactMap { $0 }
            .sink { encounteredError in
                error = encounteredError
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        editPageUseCase.resultPublisher
            .compactMap { $0 }
            .sink { encounteredResult in
                result = encounteredResult
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        waitForExpectations(timeout: 5)
        
        XCTAssertNotNil(error)
        XCTAssertNil(result)
    }
}
