//
//  URLSessionNetworkProtocol.swift
//  Doolda
//
//  Created by 김민주 on 2021/11/06.
//

import Combine
import Foundation

protocol URLSessionNetworkProtocol {
    func request<T: Decodable>(_ urlRequest: URLRequestBuilder, model: T.Type) -> AnyPublisher<T, Error>
}
