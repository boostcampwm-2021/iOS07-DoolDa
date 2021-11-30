//
//  ImageUseCaseTest.swift
//  ImageUseCaseTest
//
//  Created by Dozzing on 2021/11/30.
//

import Combine
import CoreImage
import XCTest

class ImageUseCaseTest: XCTestCase {
    private var cancellables: Set<AnyCancellable> = []

    override func tearDownWithError() throws {
        self.cancellables.removeAll()
    }

    func testSaveLocalSuccess() {
        guard let dummyUrl = URL(string: "http://naver.com"),
              let imageUrl = URL(string: "https://user-images.githubusercontent.com/61934702/132952591-74350741-dac8-4295-9f72-33e9f382cb46.png"),
              let dummyImage: CIImage = CIImage(contentsOf: imageUrl) else {
            XCTFail("Fail to initailize")
            return
        }

        let mockImageRepository = DummyImageRepository(dummyUrl: dummyUrl)
        let imageUseCase = ImageUseCase(imageRepository: mockImageRepository)

        let expectation = self.expectation(description: "testImageUseCase")

        var resultUrl: URL?

        imageUseCase.saveLocal(image: dummyImage)
            .sink { completion in
                guard case .failure(let error) = completion else { return }
                XCTFail("\(error.localizedDescription)")
                expectation.fulfill()
            } receiveValue: { url in
                resultUrl = url
                expectation.fulfill()
            }
            .store(in: &self.cancellables)

        waitForExpectations(timeout: 5)

        XCTAssertEqual(dummyUrl, resultUrl)
    }

    func testSaveLocalFailure() {
        guard let dummyUrl = URL(string: "http://naver.com"),
              let dummyImageUrl = URL(string: "https://user-images.githubusercontent.com/61934702/132952591-74350741-dac8-4295-9f72-33e9f382cb46.png"),
              let dummyImage: CIImage = CIImage(contentsOf: dummyImageUrl) else {
                  XCTFail("Fail to initailize")
                  return
              }

        let mockImageRepository = DummyImageRepository(isSuccessMode: false, dummyUrl: dummyUrl)
        let imageUseCase = ImageUseCase(imageRepository: mockImageRepository)

        let expectation = self.expectation(description: "testImageUseCase")

        imageUseCase.saveLocal(image: dummyImage)
            .sink { completion in
                guard case .failure(let error) = completion else { return }
                XCTAssertNotNil(error)
                expectation.fulfill()
            } receiveValue: { _ in
                XCTFail()
                expectation.fulfill()
            }
            .store(in: &self.cancellables)

        waitForExpectations(timeout: 5)
    }

    func testSaveRemoteSuccess() {
        guard let dummyUrl = URL(string: "http://naver.com"),
              let dummyImageUrl = URL(string: "https://user-images.githubusercontent.com/61934702/132952591-74350741-dac8-4295-9f72-33e9f382cb46.png") else {
            XCTFail("Fail to initailize")
            return
        }

        let mockImageRepository = DummyImageRepository(dummyUrl: dummyUrl)
        let imageUseCase = ImageUseCase(imageRepository: mockImageRepository)
        let dummyUser = User(id: DDID(), pairId: DDID(), friendId: DDID())

        let expectation = self.expectation(description: "testImageUseCase")

        var resultUrl: URL?

        imageUseCase.saveRemote(for: dummyUser, localUrl: dummyImageUrl)
            .sink { completion in
                guard case .failure(let error) = completion else { return }
                XCTFail("\(error.localizedDescription)")
                expectation.fulfill()
            } receiveValue: { url in
                resultUrl = url
                expectation.fulfill()
            }
            .store(in: &self.cancellables)

        waitForExpectations(timeout: 5)

        XCTAssertEqual(dummyUrl, resultUrl)
    }

}
