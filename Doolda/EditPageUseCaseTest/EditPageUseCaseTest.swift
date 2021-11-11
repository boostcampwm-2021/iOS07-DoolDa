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
            .store(in: &self.cancellables)
        
        editPageUseCase.resultPublisher
            .compactMap { $0 }
            .sink { encounteredResult in
                result = encounteredResult
                expectation.fulfill()
            }
            .store(in: &self.cancellables)
        
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
            .store(in: &self.cancellables)
        
        editPageUseCase.resultPublisher
            .compactMap { $0 }
            .sink { encounteredResult in
                result = encounteredResult
            }
            .store(in: &self.cancellables)
        
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
            .store(in: &self.cancellables)
        
        editPageUseCase.resultPublisher
            .compactMap { $0 }
            .sink { encounteredResult in
                result = encounteredResult
                expectation.fulfill()
            }
            .store(in: &self.cancellables)
        
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
            .store(in: &self.cancellables)
        
        editPageUseCase.resultPublisher
            .compactMap { $0 }
            .sink { encounteredResult in
                result = encounteredResult
                expectation.fulfill()
            }
            .store(in: &self.cancellables)
        
        waitForExpectations(timeout: 5)
        
        XCTAssertNotNil(error)
        XCTAssertNil(result)
    }
    
    func testSelectComponentWithOriginSuccess() {
        let editPageUseCase = EditPageUseCase(
            imageUseCase: DummyImageUseCase(isSuccessMode: true),
            pageRepository: DummyPageRepository(isSuccessMode: true),
            rawPageRepository: DummyRawPageRepository(isSuccessMode: true)
        )
        
        let expectation = self.expectation(description: "testSelectComponentWithOriginSuccess")

        let targetComponent = ComponentEntity(frame: CGRect(x: 0, y: 0, width: 10, height: 10), scale: 1.0, angle: 0, aspectRatio: 1)
        editPageUseCase.addComponent(targetComponent)
        
        var result: ComponentEntity?
        
        editPageUseCase.selectedComponentPublisher
            .dropFirst()
            .sink { component in
                result = component
                expectation.fulfill()
            }
            .store(in: &self.cancellables)
        editPageUseCase.selectComponent(at: CGPoint(x: 0, y: 0))
        
        waitForExpectations(timeout: 5)
            
        XCTAssertEqual(result, targetComponent)
    }
    
    func testSelectComponentWithRightTopSuccess() {
        let editPageUseCase = EditPageUseCase(
            imageUseCase: DummyImageUseCase(isSuccessMode: true),
            pageRepository: DummyPageRepository(isSuccessMode: true),
            rawPageRepository: DummyRawPageRepository(isSuccessMode: true)
        )
        
        let expectation = self.expectation(description: "testSelectComponentWithRightTopSuccess")

        let targetComponent = ComponentEntity(frame: CGRect(x: 0, y: 0, width: 10, height: 10), scale: 1.0, angle: 0, aspectRatio: 1)
        editPageUseCase.addComponent(targetComponent)
        
        var result: ComponentEntity?
        
        editPageUseCase.selectedComponentPublisher
            .dropFirst()
            .sink { component in
                result = component
                expectation.fulfill()
            }
            .store(in: &self.cancellables)
        editPageUseCase.selectComponent(at: CGPoint(x: 9.9, y: 0))
        
        waitForExpectations(timeout: 5)
            
        XCTAssertEqual(result, targetComponent)
    }
    
    func testSelectComponentWithRightTopFailure() {
        let editPageUseCase = EditPageUseCase(
            imageUseCase: DummyImageUseCase(isSuccessMode: true),
            pageRepository: DummyPageRepository(isSuccessMode: true),
            rawPageRepository: DummyRawPageRepository(isSuccessMode: true)
        )
        
        let expectation = self.expectation(description: "testSelectComponentWithRightTopFailure")

        let targetComponent = ComponentEntity(frame: CGRect(x: 0, y: 0, width: 10, height: 10), scale: 1.0, angle: 0, aspectRatio: 1)
        editPageUseCase.addComponent(targetComponent)
        
        var result: ComponentEntity?
        
        editPageUseCase.selectedComponentPublisher
            .dropFirst()
            .sink { component in
                result = component
                expectation.fulfill()
            }
            .store(in: &self.cancellables)
        editPageUseCase.selectComponent(at: CGPoint(x: 10, y: 0))
        
        waitForExpectations(timeout: 5)
            
        XCTAssertNil(result)
    }
    
    func testSelectComponentWithLeftBottomSuccess() {
        let editPageUseCase = EditPageUseCase(
            imageUseCase: DummyImageUseCase(isSuccessMode: true),
            pageRepository: DummyPageRepository(isSuccessMode: true),
            rawPageRepository: DummyRawPageRepository(isSuccessMode: true)
        )
        
        let expectation = self.expectation(description: "testSelectComponentWithLeftBottomSuccess")

        let targetComponent = ComponentEntity(frame: CGRect(x: 0, y: 0, width: 10, height: 10), scale: 1.0, angle: 0, aspectRatio: 1)
        editPageUseCase.addComponent(targetComponent)
        
        var result: ComponentEntity?
        
        editPageUseCase.selectedComponentPublisher
            .dropFirst()
            .sink { component in
                result = component
                expectation.fulfill()
            }
            .store(in: &self.cancellables)
        editPageUseCase.selectComponent(at: CGPoint(x: 0, y: 9.9))
        
        waitForExpectations(timeout: 5)
            
        XCTAssertEqual(result, targetComponent)
    }
    
    func testSelectComponentWithLeftBottomFailure() {
        let editPageUseCase = EditPageUseCase(
            imageUseCase: DummyImageUseCase(isSuccessMode: true),
            pageRepository: DummyPageRepository(isSuccessMode: true),
            rawPageRepository: DummyRawPageRepository(isSuccessMode: true)
        )
        
        let expectation = self.expectation(description: "testSelectComponentWithLeftBottomFailure")

        let targetComponent = ComponentEntity(frame: CGRect(x: 0, y: 0, width: 10, height: 10), scale: 1.0, angle: 0, aspectRatio: 1)
        editPageUseCase.addComponent(targetComponent)
        
        var result: ComponentEntity?
        
        editPageUseCase.selectedComponentPublisher
            .dropFirst()
            .sink { component in
                result = component
                expectation.fulfill()
            }
            .store(in: &self.cancellables)
        editPageUseCase.selectComponent(at: CGPoint(x: 0, y: 10))
        
        waitForExpectations(timeout: 5)
            
        XCTAssertNil(result)
    }
    
    func testSelectComponentWithRightBotomSuccess() {
        let editPageUseCase = EditPageUseCase(
            imageUseCase: DummyImageUseCase(isSuccessMode: true),
            pageRepository: DummyPageRepository(isSuccessMode: true),
            rawPageRepository: DummyRawPageRepository(isSuccessMode: true)
        )
        
        let expectation = self.expectation(description: "testSelectComponentWithRightBotomSuccess")

        let targetComponent = ComponentEntity(frame: CGRect(x: 0, y: 0, width: 10, height: 10), scale: 1.0, angle: 0, aspectRatio: 1)
        editPageUseCase.addComponent(targetComponent)
        
        var result: ComponentEntity?
        
        editPageUseCase.selectedComponentPublisher
            .dropFirst()
            .sink { component in
                result = component
                expectation.fulfill()
            }
            .store(in: &self.cancellables)
        editPageUseCase.selectComponent(at: CGPoint(x: 9.9, y: 9.9))
        
        waitForExpectations(timeout: 5)
            
        XCTAssertEqual(result, targetComponent)
    }
    
    func testSelectComponentWithRightBotomFailure() {
        let editPageUseCase = EditPageUseCase(
            imageUseCase: DummyImageUseCase(isSuccessMode: true),
            pageRepository: DummyPageRepository(isSuccessMode: true),
            rawPageRepository: DummyRawPageRepository(isSuccessMode: true)
        )
        
        let expectation = self.expectation(description: "testSelectComponentWithRightBotomFailure")

        let targetComponent = ComponentEntity(frame: CGRect(x: 0, y: 0, width: 10, height: 10), scale: 1.0, angle: 0, aspectRatio: 1)
        editPageUseCase.addComponent(targetComponent)
        
        var result: ComponentEntity?
        
        editPageUseCase.selectedComponentPublisher
            .dropFirst()
            .sink { component in
                result = component
                expectation.fulfill()
            }
            .store(in: &self.cancellables)
        editPageUseCase.selectComponent(at: CGPoint(x: 10, y: 10))
        
        waitForExpectations(timeout: 5)
            
        XCTAssertNil(result)
    }
    
    func testSelectScaledComponentWithRightBotomSuccess() {
        let editPageUseCase = EditPageUseCase(
            imageUseCase: DummyImageUseCase(isSuccessMode: true),
            pageRepository: DummyPageRepository(isSuccessMode: true),
            rawPageRepository: DummyRawPageRepository(isSuccessMode: true)
        )
        
        let expectation = self.expectation(description: "testSelectScaledComponentWithRightBotomSuccess")

        let targetComponent = ComponentEntity(frame: CGRect(x: 0, y: 0, width: 10, height: 10), scale: 2, angle: 0, aspectRatio: 1)
        editPageUseCase.addComponent(targetComponent)
        
        var result: ComponentEntity?
        
        editPageUseCase.selectedComponentPublisher
            .dropFirst()
            .sink { component in
                result = component
                expectation.fulfill()
            }
            .store(in: &self.cancellables)
        editPageUseCase.selectComponent(at: CGPoint(x: 14.9, y: 14.9))
        
        waitForExpectations(timeout: 5)
            
        XCTAssertEqual(result, targetComponent)
    }
    
    func testSelectScaledComponentWithRightBotomFailure() {
        let editPageUseCase = EditPageUseCase(
            imageUseCase: DummyImageUseCase(isSuccessMode: true),
            pageRepository: DummyPageRepository(isSuccessMode: true),
            rawPageRepository: DummyRawPageRepository(isSuccessMode: true)
        )
        
        let expectation = self.expectation(description: "testSelectScaledComponentWithRightBotomFailure")

        let targetComponent = ComponentEntity(frame: CGRect(x: 0, y: 0, width: 10, height: 10), scale: 2, angle: 0, aspectRatio: 1)
        editPageUseCase.addComponent(targetComponent)
        
        var result: ComponentEntity?
        
        editPageUseCase.selectedComponentPublisher
            .dropFirst()
            .sink { component in
                result = component
                expectation.fulfill()
            }
            .store(in: &self.cancellables)
        editPageUseCase.selectComponent(at: CGPoint(x: 15, y: 15))
        
        waitForExpectations(timeout: 5)
            
        XCTAssertNil(result)
    }
    
    func testSelectRotatedComponentWithRightBotomSuccess() {
        let editPageUseCase = EditPageUseCase(
            imageUseCase: DummyImageUseCase(isSuccessMode: true),
            pageRepository: DummyPageRepository(isSuccessMode: true),
            rawPageRepository: DummyRawPageRepository(isSuccessMode: true)
        )
        
        let expectation = self.expectation(description: "testSelectRotatedComponentWithRightBotomSuccess")

        let targetComponent = ComponentEntity(frame: CGRect(x: 0, y: 0, width: 5, height: 10), scale: 1, angle: CGFloat(90).degreeToRadian, aspectRatio: 1)
        editPageUseCase.addComponent(targetComponent)
        
        var result: ComponentEntity?
        
        editPageUseCase.selectedComponentPublisher
            .dropFirst()
            .sink { component in
                result = component
                expectation.fulfill()
            }
            .store(in: &self.cancellables)
        editPageUseCase.selectComponent(at: CGPoint(x: 7.4, y: 7.4))
        
        waitForExpectations(timeout: 5)
            
        XCTAssertEqual(result, targetComponent)
    }
    
    func testSelectRotatedComponentWithRightBotomFailure() {
        let editPageUseCase = EditPageUseCase(
            imageUseCase: DummyImageUseCase(isSuccessMode: true),
            pageRepository: DummyPageRepository(isSuccessMode: true),
            rawPageRepository: DummyRawPageRepository(isSuccessMode: true)
        )
        
        let expectation = self.expectation(description: "testSelectRotatedComponentWithRightBotomFailure")

        let targetComponent = ComponentEntity(frame: CGRect(x: 0, y: 0, width: 5, height: 10), scale: 1, angle: CGFloat(90).degreeToRadian, aspectRatio: 1)
        editPageUseCase.addComponent(targetComponent)
        
        var result: ComponentEntity?
        
        editPageUseCase.selectedComponentPublisher
            .dropFirst()
            .sink { component in
                result = component
                expectation.fulfill()
            }
            .store(in: &self.cancellables)
        editPageUseCase.selectComponent(at: CGPoint(x: 7.5, y: 7.5))
        
        waitForExpectations(timeout: 5)
            
        XCTAssertNil(result)
    }
    
    func testSelectOneAmongComponentsSuccess() {
        let editPageUseCase = EditPageUseCase(
            imageUseCase: DummyImageUseCase(isSuccessMode: true),
            pageRepository: DummyPageRepository(isSuccessMode: true),
            rawPageRepository: DummyRawPageRepository(isSuccessMode: true)
        )
        
        let expectation = self.expectation(description: "testSelectOneAmongComponentsSuccess")

        let targetComponent = ComponentEntity(frame: CGRect(x: 0, y: 0, width: 5, height: 10), scale: 1, angle: CGFloat(90).degreeToRadian, aspectRatio: 1)
        editPageUseCase.addComponent(ComponentEntity(frame: CGRect(x: 0, y: 0, width: 10, height: 10), scale: 2, angle: 0, aspectRatio: 1))
        editPageUseCase.addComponent(ComponentEntity(frame: CGRect(x: 0, y: 0, width: 10, height: 10), scale: 1.0, angle: 0, aspectRatio: 1))
        editPageUseCase.addComponent(targetComponent)
        
        var result: ComponentEntity?
        
        editPageUseCase.selectedComponentPublisher
            .dropFirst()
            .sink { component in
                result = component
                expectation.fulfill()
            }
            .store(in: &self.cancellables)
        editPageUseCase.selectComponent(at: CGPoint(x: 7.4, y: 7.4))
        
        waitForExpectations(timeout: 5)
            
        XCTAssertEqual(result, targetComponent)
    }
    
    func testSelectOneAmongComponentsFailure() {
        let editPageUseCase = EditPageUseCase(
            imageUseCase: DummyImageUseCase(isSuccessMode: true),
            pageRepository: DummyPageRepository(isSuccessMode: true),
            rawPageRepository: DummyRawPageRepository(isSuccessMode: true)
        )
        
        let expectation = self.expectation(description: "testSelectOneAmongComponentsFailure")

        let targetComponent = ComponentEntity(frame: CGRect(x: 0, y: 0, width: 5, height: 10), scale: 1, angle: CGFloat(90).degreeToRadian, aspectRatio: 1)
        editPageUseCase.addComponent(ComponentEntity(frame: CGRect(x: 0, y: 0, width: 10, height: 10), scale: 2, angle: 0, aspectRatio: 1))
        editPageUseCase.addComponent(ComponentEntity(frame: CGRect(x: 0, y: 0, width: 10, height: 10), scale: 1.0, angle: 0, aspectRatio: 1))
        editPageUseCase.addComponent(targetComponent)
        
        var result: ComponentEntity?
        
        editPageUseCase.selectedComponentPublisher
            .dropFirst()
            .sink { component in
                result = component
                expectation.fulfill()
            }
            .store(in: &self.cancellables)
        editPageUseCase.selectComponent(at: CGPoint(x: 7.5, y: 7.5))
        
        waitForExpectations(timeout: 5)
            
        XCTAssertNotEqual(result, targetComponent)
    }
    
    func testMoveSelectedComponentSuccess() {
        let editPageUseCase = EditPageUseCase(
            imageUseCase: DummyImageUseCase(isSuccessMode: true),
            pageRepository: DummyPageRepository(isSuccessMode: true),
            rawPageRepository: DummyRawPageRepository(isSuccessMode: true)
        )
        
        let expectation = self.expectation(description: "testMoveSelectedComponentSuccess")
        
        let targetComponent = ComponentEntity(frame: CGRect(x: 0, y: 0, width: 10, height: 10), scale: 1.0, angle: 0, aspectRatio: 1)
        editPageUseCase.addComponent(targetComponent)
        
        var result: ComponentEntity?
        
        editPageUseCase.selectComponent(at: CGPoint(x: 9.9, y: 9.9))
        editPageUseCase.moveComponent(to: CGPoint(x: 10, y: 10))
        editPageUseCase.selectedComponentPublisher
            .dropFirst()
            .sink { component in
                result = component
                expectation.fulfill()
            }
            .store(in: &self.cancellables)
        editPageUseCase.selectComponent(at: CGPoint(x: 10, y: 10))
        
        waitForExpectations(timeout: 5)
        
        XCTAssertEqual(result, targetComponent)
    }
    
    func testMoveSelectedComponentFailure() {
        let editPageUseCase = EditPageUseCase(
            imageUseCase: DummyImageUseCase(isSuccessMode: true),
            pageRepository: DummyPageRepository(isSuccessMode: true),
            rawPageRepository: DummyRawPageRepository(isSuccessMode: true)
        )
        
        let expectation = self.expectation(description: "testMoveSelectedComponentFailure")
        
        let targetComponent = ComponentEntity(frame: CGRect(x: 0, y: 0, width: 10, height: 10), scale: 1.0, angle: 0, aspectRatio: 1)
        editPageUseCase.addComponent(targetComponent)
        
        var result: ComponentEntity?
        
        editPageUseCase.selectComponent(at: CGPoint(x: 9.9, y: 9.9))
        editPageUseCase.moveComponent(to: CGPoint(x: 10, y: 10))
        editPageUseCase.selectedComponentPublisher
            .dropFirst()
            .sink { component in
                result = component
                expectation.fulfill()
            }
            .store(in: &self.cancellables)
        editPageUseCase.selectComponent(at: CGPoint(x: 20, y: 20))
        
        waitForExpectations(timeout: 5)
        
        XCTAssertNil(result)
    }
    
    func testScaleSelectedComponentSuccess() {
        let editPageUseCase = EditPageUseCase(
            imageUseCase: DummyImageUseCase(isSuccessMode: true),
            pageRepository: DummyPageRepository(isSuccessMode: true),
            rawPageRepository: DummyRawPageRepository(isSuccessMode: true)
        )
        
        let expectation = self.expectation(description: "testScaleSelectedComponentSuccess")
        
        let targetComponent = ComponentEntity(frame: CGRect(x: 0, y: 0, width: 10, height: 10), scale: 1.0, angle: 0, aspectRatio: 1)
        editPageUseCase.addComponent(targetComponent)
        
        var result: ComponentEntity?
        
        editPageUseCase.selectComponent(at: CGPoint(x: 9.9, y: 9.9))
        editPageUseCase.scaleComponent(by: 2)
        editPageUseCase.selectedComponentPublisher
            .dropFirst()
            .sink { component in
                result = component
                expectation.fulfill()
            }
            .store(in: &self.cancellables)
        editPageUseCase.selectComponent(at: CGPoint(x: 14.9, y: 14.9))
        
        waitForExpectations(timeout: 5)
        
        XCTAssertEqual(result, targetComponent)
    }
    
    func testScaleSelectedComponentFailure() {
        let editPageUseCase = EditPageUseCase(
            imageUseCase: DummyImageUseCase(isSuccessMode: true),
            pageRepository: DummyPageRepository(isSuccessMode: true),
            rawPageRepository: DummyRawPageRepository(isSuccessMode: true)
        )
        
        let expectation = self.expectation(description: "testScaleSelectedComponentFailure")
        
        let targetComponent = ComponentEntity(frame: CGRect(x: 0, y: 0, width: 10, height: 10), scale: 1.0, angle: 0, aspectRatio: 1)
        editPageUseCase.addComponent(targetComponent)
        
        var result: ComponentEntity?
        
        editPageUseCase.selectComponent(at: CGPoint(x: 9.9, y: 9.9))
        editPageUseCase.scaleComponent(by: 2)
        editPageUseCase.selectedComponentPublisher
            .dropFirst()
            .sink { component in
                result = component
                expectation.fulfill()
            }
            .store(in: &self.cancellables)
        editPageUseCase.selectComponent(at: CGPoint(x: 15, y: 15))
        
        waitForExpectations(timeout: 5)
        
        XCTAssertNil(result)
    }
    
    func testRotateSelectedComponentSuccess() {
        let editPageUseCase = EditPageUseCase(
            imageUseCase: DummyImageUseCase(isSuccessMode: true),
            pageRepository: DummyPageRepository(isSuccessMode: true),
            rawPageRepository: DummyRawPageRepository(isSuccessMode: true)
        )
        
        let expectation = self.expectation(description: "testRotateSelectedComponentSuccess")

        let targetComponent = ComponentEntity(frame: CGRect(x: 0, y: 0, width: 5, height: 10), scale: 1, angle: 0, aspectRatio: 1)
        editPageUseCase.addComponent(targetComponent)
        
        var result: ComponentEntity?
        
        editPageUseCase.selectComponent(at: CGPoint(x: 2.5, y: 5))
        editPageUseCase.rotateComponent(by: CGFloat(90).degreeToRadian)
        editPageUseCase.selectedComponentPublisher
            .dropFirst()
            .sink { component in
                result = component
                expectation.fulfill()
            }
            .store(in: &self.cancellables)
        editPageUseCase.selectComponent(at: CGPoint(x: 7.4, y: 7.4))
        
        waitForExpectations(timeout: 5)
            
        XCTAssertEqual(result, targetComponent)
    }
    
    func testRotateSelectedComponentFailure() {
        let editPageUseCase = EditPageUseCase(
            imageUseCase: DummyImageUseCase(isSuccessMode: true),
            pageRepository: DummyPageRepository(isSuccessMode: true),
            rawPageRepository: DummyRawPageRepository(isSuccessMode: true)
        )
        
        let expectation = self.expectation(description: "testRotateSelectedComponentFailure")

        let targetComponent = ComponentEntity(frame: CGRect(x: 0, y: 0, width: 5, height: 10), scale: 1, angle: 0, aspectRatio: 1)
        editPageUseCase.addComponent(targetComponent)
        
        var result: ComponentEntity?
        
        editPageUseCase.selectComponent(at: CGPoint(x: 2.5, y: 5))
        editPageUseCase.rotateComponent(by: CGFloat(90).degreeToRadian)
        editPageUseCase.selectedComponentPublisher
            .dropFirst()
            .sink { component in
                result = component
                expectation.fulfill()
            }
            .store(in: &self.cancellables)
        editPageUseCase.selectComponent(at: CGPoint(x: 7.5, y: 7.5))
        
        waitForExpectations(timeout: 5)
            
        XCTAssertNil(result)
    }
    
    func testSendComponentBack() {
        let editPageUseCase = EditPageUseCase(
            imageUseCase: DummyImageUseCase(isSuccessMode: true),
            pageRepository: DummyPageRepository(isSuccessMode: true),
            rawPageRepository: DummyRawPageRepository(isSuccessMode: true)
        )
        
        let a = ComponentEntity(frame: CGRect(x: 0, y: 0, width: 10, height: 10), scale: 1, angle: 0, aspectRatio: 1)
        let b = ComponentEntity(frame: CGRect(x: 1, y: 1, width: 10, height: 10), scale: 1, angle: 0, aspectRatio: 1)
        let c = ComponentEntity(frame: CGRect(x: 2, y: 2, width: 10, height: 10), scale: 1, angle: 0, aspectRatio: 1)
        let d = ComponentEntity(frame: CGRect(x: 3, y: 3, width: 10, height: 10), scale: 1, angle: 0, aspectRatio: 1)
        let e = ComponentEntity(frame: CGRect(x: 4, y: 4, width: 10, height: 10), scale: 1, angle: 0, aspectRatio: 1)
        let f = ComponentEntity(frame: CGRect(x: 5, y: 5, width: 10, height: 10), scale: 1, angle: 0, aspectRatio: 1)
        
        editPageUseCase.addComponent(a)
        editPageUseCase.addComponent(b)
        editPageUseCase.addComponent(c)
        editPageUseCase.addComponent(d)
        editPageUseCase.addComponent(e)
        editPageUseCase.addComponent(f)
        
        var result: [ComponentEntity]?
        
        let expectation = self.expectation(description: "testSendComponentBack")
        expectation.expectedFulfillmentCount = 3
        
        editPageUseCase.rawPagePublisher
            .dropFirst()
            .sink { rawPage in
                result = rawPage?.components
                expectation.fulfill()
            }
            .store(in: &self.cancellables)
        editPageUseCase.selectComponent(at: CGPoint(x: 5, y: 5))
        editPageUseCase.sendComponentBack()
        editPageUseCase.selectComponent(at: CGPoint(x: 4, y: 4))
        editPageUseCase.sendComponentBack()
        editPageUseCase.selectComponent(at: CGPoint(x: 3, y: 3))
        editPageUseCase.sendComponentBack()
        waitForExpectations(timeout: 5)
        
        XCTAssertEqual([d, e, f, a, b, c], result)
    }
    
    func testBringComponentFront() {
        let editPageUseCase = EditPageUseCase(
            imageUseCase: DummyImageUseCase(isSuccessMode: true),
            pageRepository: DummyPageRepository(isSuccessMode: true),
            rawPageRepository: DummyRawPageRepository(isSuccessMode: true)
        )
        
        let a = ComponentEntity(frame: CGRect(x: 0, y: 0, width: 10, height: 10), scale: 1, angle: 0, aspectRatio: 1)
        let b = ComponentEntity(frame: CGRect(x: 1, y: 1, width: 10, height: 10), scale: 1, angle: 0, aspectRatio: 1)
        let c = ComponentEntity(frame: CGRect(x: 2, y: 2, width: 10, height: 10), scale: 1, angle: 0, aspectRatio: 1)
        let d = ComponentEntity(frame: CGRect(x: 3, y: 3, width: 10, height: 10), scale: 1, angle: 0, aspectRatio: 1)
        let e = ComponentEntity(frame: CGRect(x: 4, y: 4, width: 10, height: 10), scale: 1, angle: 0, aspectRatio: 1)
        let f = ComponentEntity(frame: CGRect(x: 5, y: 5, width: 10, height: 10), scale: 1, angle: 0, aspectRatio: 1)
        
        editPageUseCase.addComponent(a)
        editPageUseCase.addComponent(b)
        editPageUseCase.addComponent(c)
        editPageUseCase.addComponent(d)
        editPageUseCase.addComponent(e)
        editPageUseCase.addComponent(f)
        
        var result: [ComponentEntity]?
        
        let expectation = self.expectation(description: "testBringComponentFront")
        expectation.expectedFulfillmentCount = 3
        
        editPageUseCase.rawPagePublisher
            .dropFirst()
            .sink { rawPage in
                result = rawPage?.components
                expectation.fulfill()
            }
            .store(in: &self.cancellables)
        editPageUseCase.selectComponent(at: CGPoint(x: 2, y: 2))
        editPageUseCase.bringComponentFront()
        editPageUseCase.selectComponent(at: CGPoint(x: 1, y: 1))
        editPageUseCase.bringComponentFront()
        editPageUseCase.selectComponent(at: CGPoint(x: 0, y: 0))
        editPageUseCase.bringComponentFront()
        waitForExpectations(timeout: 5)
        
        XCTAssertEqual([d, e, f, c, b, a], result)
    }
    
    func testRemoveComponentSingle() {
        let editPageUseCase = EditPageUseCase(
            imageUseCase: DummyImageUseCase(isSuccessMode: true),
            pageRepository: DummyPageRepository(isSuccessMode: true),
            rawPageRepository: DummyRawPageRepository(isSuccessMode: true)
        )
        
        let expectation = self.expectation(description: "testRemoveComponentSingle")
        
        editPageUseCase.addComponent(ComponentEntity(frame: CGRect(x: 0, y: 0, width: 10, height: 10), scale: 1, angle: 0, aspectRatio: 1))
        
        var result: ComponentEntity?
        var isEmpty: Bool? = false
        
        editPageUseCase.selectComponent(at: CGPoint(x: 0, y: 0))
        Publishers.Zip(editPageUseCase.selectedComponentPublisher, editPageUseCase.rawPagePublisher)
            .dropFirst()
            .sink { (selectedComponent, rawPage) in
                result = selectedComponent
                isEmpty = rawPage?.components.isEmpty
                expectation.fulfill()
            }
            .store(in: &self.cancellables)
        
        editPageUseCase.removeComponent()
        
        waitForExpectations(timeout: 5)
            
        XCTAssertNil(result)
        XCTAssertTrue(isEmpty ?? false)
    }
    
    func testRemoveComponentDouble() {
        let editPageUseCase = EditPageUseCase(
            imageUseCase: DummyImageUseCase(isSuccessMode: true),
            pageRepository: DummyPageRepository(isSuccessMode: true),
            rawPageRepository: DummyRawPageRepository(isSuccessMode: true)
        )
        
        let expectation = self.expectation(description: "testRemoveComponentDouble")
        
        editPageUseCase.addComponent(ComponentEntity(frame: CGRect(x: 0, y: 0, width: 10, height: 10), scale: 1, angle: 0, aspectRatio: 1))
        editPageUseCase.addComponent(ComponentEntity(frame: CGRect(x: 0, y: 0, width: 10, height: 10), scale: 1, angle: 0, aspectRatio: 1))
        
        var result: ComponentEntity?
        var isEmpty: Bool? = false
        
        editPageUseCase.selectComponent(at: CGPoint(x: 0, y: 0))
        Publishers.Zip(editPageUseCase.selectedComponentPublisher, editPageUseCase.rawPagePublisher)
            .dropFirst()
            .sink { (selectedComponent, rawPage) in
                result = selectedComponent
                isEmpty = rawPage?.components.isEmpty
                expectation.fulfill()
            }
            .store(in: &self.cancellables)
        
        editPageUseCase.removeComponent()
        
        waitForExpectations(timeout: 5)
            
        XCTAssertNil(result)
        XCTAssertFalse(isEmpty ?? true)
    }
}
