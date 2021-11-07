//
//  URLSessionNetworkService.swift
//  Doolda
//
//  Created by 김민주 on 2021/11/06.
//

import Combine
import Foundation
import Accelerate

class URLSessionNetworkService {
    enum Errors: LocalizedError {
         case invalidUrl
         
         var errorDescription: String? {
             switch self {
             case .invalidUrl:
                 return "유효하지 않은 URL입니다."
             }
         }
     }
    
    private let session: URLSession
    private let decoder: JSONDecoder
    
    // MARK: - Initializers
    
    init() {
        self.session = .shared
        self.decoder = JSONDecoder()
    }
    
    func request<T: Decodable>(_ urlRequest: URLRequestBuilder) -> AnyPublisher<T, Error> {
        guard let urlRequset = urlRequest.urlRequest else {
            return Fail(error: Errors.invalidUrl).eraseToAnyPublisher()
        }
        return self.session.dataTaskPublisher(for: urlRequset)
            .tryMap { data, response in
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
            .decode(type: T.self, decoder: decoder)
            .eraseToAnyPublisher()
    }
}
