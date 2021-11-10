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
            XCTFail()
            return
        }

        let urlRequest = FirebaseAPIs.createStorageFile(pairId, fileName, fileData)
        let publisher: AnyPublisher<Data, Error> = networkService.request(urlRequest)
        let subscriber = publisher
            .sink { completion in
                guard case .failure( _) = completion else { return }
                XCTFail()
            } receiveValue: { data in
                guard let dataString = String(data: data, encoding: .utf8) else {
                    XCTFail()
                    return
                }
                XCTAssertEqual(fileContent, dataString)
                expectation.fulfill()
            }
            
        wait(for: [expectation], timeout: 10)
        subscriber.cancel()
    }

}
