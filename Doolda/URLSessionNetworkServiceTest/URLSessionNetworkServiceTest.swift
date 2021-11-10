//
//  URLSessionNetworkServiceTest.swift
//  URLSessionNetworkServiceTest
//
//  Created by Dozzing on 2021/11/10.
//

import Combine
import XCTest
@testable import Doolda

class URLSessionNetworkServiceTest: XCTestCase {
    private var networkService: URLSessionNetworkServiceProtocol?
    var cancellableSet: Set<AnyCancellable> = []

    override func setUpWithError() throws {
        self.networkService = URLSessionNetworkService()
    }

    func testCreateStorageFileSuccess() throws {
        guard let networkService = self.networkService else {
            XCTFail()
            return
        }

        let expectation = XCTestExpectation()

        let pairId = "testPairId"
        let fileName = "testFileName"
        let fileContent = "Hello this is Doolda Firebase Storage test"
        guard let fileData = fileContent.data(using: .utf8) else {
            XCTFail("Dummy fileContent error")
            return
        }

        let urlRequest = FirebaseAPIs.createStorageFile(pairId, fileName, fileData)
        let publisher: AnyPublisher<[String: String], Error> = networkService.request(urlRequest)

        publisher
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { completion in
                guard case .failure(let error) = completion else { return }
                XCTFail("\(error.localizedDescription)")
                expectation.fulfill()
            } receiveValue: { result in
                guard let fileName = result["name"] else {
                    XCTFail("wrong file result")
                    expectation.fulfill()
                    return
                }
                XCTAssertEqual("testPairId/testFileName", fileName)
                expectation.fulfill()
            }
            .store(in: &cancellableSet)
            
        wait(for: [expectation], timeout: 30)
    }

}
