//
//  ImageUseCaseTest.swift
//  ImageUseCaseTest
//
//  Created by Dozzing on 2021/11/30.
//

import Combine
import XCTest

class ImageUseCaseTest: XCTestCase {
    private var cancellables: Set<AnyCancellable> = []

    override func tearDownWithError() throws {
        self.cancellables.removeAll()
    }

    func testSaveRemote() {
        let mockImageRepository = DummyImageRepository()
        let imageUseCase = ImageUseCase(imageRepository: mockImageRepository)
    }

}
