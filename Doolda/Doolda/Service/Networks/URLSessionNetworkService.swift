//
//  URLSessionNetworkService.swift
//  Doolda
//
//  Created by 김민주 on 2021/11/06.
//

import Combine
import Foundation
import FirebaseAuth
import Accelerate

final class URLSessionNetworkService: URLSessionNetworkServiceProtocol {
    enum Errors: LocalizedError {
         case invalidUrl
         
         var errorDescription: String? {
             switch self {
             case .invalidUrl:
                 return "유효하지 않은 URL입니다."
             }
         }
     }
    
    static let shared: URLSessionNetworkService = URLSessionNetworkService()
    
    private let session: URLSession = .shared
    private let decoder: JSONDecoder = JSONDecoder()
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Initializers
    
    private init() {}
    
    func request(_ urlRequest: URLRequestBuilder) -> AnyPublisher<Data, Error> {
        let currentUser = Auth.auth().currentUser
        return Future<Data,Error> { promise in
            Future<String, Error>.init { tokenPromise in
               currentUser?.getIDTokenForcingRefresh(true) { idToken, error in
                   if let error = error {
                       tokenPromise(.failure(error))
                       return
                   }
                   tokenPromise(.success(idToken ?? ""))
               }
           }.eraseToAnyPublisher()
               .sink { completion in
                   print(completion)
               } receiveValue: { token in
                   Secrets.idToken = token
                   guard let urlRequest = urlRequest.urlRequest else { return promise(.failure(Errors.invalidUrl))}
                   self.session.dataTaskPublisher(for: urlRequest)
                       .sink(receiveCompletion: { completion in
                           print(completion)
                       }, receiveValue: { data, response in
                           guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
                               switch (response as? HTTPURLResponse)?.statusCode {
                               case .some(404):
                                   promise(.failure(Errors.invalidUrl))
                               default:
                                   promise(.failure(Errors.invalidUrl))
                               }
                               return
                           }
                           promise(.success(data))
                       }).store(in: &self.cancellables)
               }.store(in: &self.cancellables)
        }.eraseToAnyPublisher()
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
