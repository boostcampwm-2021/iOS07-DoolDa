//
//  URLSessionNetworkProtocol.swift
//  Doolda
//
//  Created by 김민주 on 2021/11/06.
//

import Combine
import Foundation

protocol URLSessionNetworkServiceProtocol {
    func request<T: Decodable>(_ urlRequest: URLRequestBuilder) -> AnyPublisher<T, Error>
}
