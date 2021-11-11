//
//  URLSessionNetworkServiceTest.swift
//  URLSessionNetworkServiceTest
//
//  Created by Dozzing on 2021/11/10.
//

import Combine
import XCTest
//@testable import Doolda

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
        let publisher: AnyPublisher<Data, Error> = networkService.request(urlRequest)

        publisher
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { completion in
                guard case .failure(let error) = completion else { return }
                XCTFail("\(error.localizedDescription)")
                expectation.fulfill()
            } receiveValue: { data in
                guard let dataString = String(data: data, encoding: .utf8) else {
                    XCTFail("encoding error")
                    expectation.fulfill()
                    return
                }
                XCTAssertEqual(fileContent, dataString)
                expectation.fulfill()
            }
            .store(in: &cancellableSet)
            
        wait(for: [expectation], timeout: 30)
    }

}


//var baseURL: URL? { get }
//var requestURL: URL? { get }
//var path: String { get }
//var parameters: [String:String]? { get }
//var method: HttpMethod { get }
//var headers: [String:String]? { get }
//var body: [String: Any]? { get }
//var binary: Data? { get }
//var urlRequest: URLRequest? { get }
