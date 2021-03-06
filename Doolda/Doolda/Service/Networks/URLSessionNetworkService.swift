//
//  URLSessionNetworkService.swift
//  Doolda
//
//  Created by 김민주 on 2021/11/06.
//

import Combine
import Foundation
import Accelerate

final class URLSessionNetworkService: URLSessionNetworkServiceProtocol {
    enum Errors: LocalizedError {
        case invalidUrl

        var errorDescription: String? {
            switch self {
            case .invalidUrl: return "유효하지 않은 URL"
            }
        }
    }
    
    static let shared: URLSessionNetworkService = URLSessionNetworkService()
    static let timeOutLimit: Int = 60
    
    private let session: URLSession = .shared
    private let scheduler = DispatchQueue.global()
    private let decoder: JSONDecoder = JSONDecoder()
    
    // MARK: - Initializers
    
    private init() {}
    
    func request(_ urlRequest: URLRequestBuilder) -> AnyPublisher<Data, Error> {
        guard let urlRequest = urlRequest.urlRequest else { return Fail(error: Errors.invalidUrl).eraseToAnyPublisher() }
        return self.session.dataTaskPublisher(for: urlRequest)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
                    switch (response as? HTTPURLResponse)?.statusCode {
                    case .some(404):
                        throw URLError(.cannotFindHost)
                    default:
                        throw URLError(.badServerResponse)
                    }
                }
                return data
            }
            .eraseToAnyPublisher()
    }
    
    func request<T: Decodable>(_ urlRequest: URLRequestBuilder) -> AnyPublisher<T, Error> {
        return request(urlRequest)
            .decode(type: T.self, decoder: decoder)
            .eraseToAnyPublisher()
    }
    
    func request(_ urlRequest: URLRequestBuilder) -> AnyPublisher<[[String: Any]], Error> {
        return request(urlRequest)
            .tryCompactMap { return try JSONSerialization.jsonObject(with: $0, options: []) as? [[String: Any]] }
            .eraseToAnyPublisher()
    }
    
    func request(_ urlRequest: URLRequestBuilder) -> AnyPublisher<[String: Any], Error> {
        return request(urlRequest)
            .tryCompactMap { return try JSONSerialization.jsonObject(with: $0, options: []) as? [String: Any] }
            .eraseToAnyPublisher()
    }
}
