//
//  URLSessionNetworkService.swift
//  Doolda
//
//  Created by 김민주 on 2021/11/06.
//

import Combine
import Foundation

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
    
    func request<T: Decodable>(_ urlRequest: URLRequestBuilder, model: T.Type) -> AnyPublisher<T, Error> {
        guard let urlRequset = urlRequest.urlRequest else {
            return Fail(error: Errors.invalidUrl).eraseToAnyPublisher()
        }
        return self.session.dataTaskPublisher(for: urlRequset)
            .tryMap { element -> Data in
                guard let httpResponse = element.response as? HTTPURLResponse,
                    httpResponse.statusCode == 200 else {
                        throw URLError(.badServerResponse)
                    }
                return element.data
                }
            .decode(type: T.self, decoder: decoder)
            .eraseToAnyPublisher()
    }
}
