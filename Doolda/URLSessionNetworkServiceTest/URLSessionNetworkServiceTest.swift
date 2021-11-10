//
//  URLSessionNetworkServiceTest.swift
//  URLSessionNetworkServiceTest
//
//  Created by Dozzing on 2021/11/10.
//

import XCTest
@testable import Doolda

class URLSessionNetworkServiceTest: XCTestCase {
    private var networkService: URLSessionNetworkServiceProtocol?

    override func setUpWithError() throws {
        self.networkService = URLSessionNetworkService()
    }


    func testExample() throws {

    }

}
