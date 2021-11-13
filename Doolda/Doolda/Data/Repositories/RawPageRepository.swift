//
//  RawPageRepository.swift
//  Doolda
//
//  Created by Seunghun Yang on 2021/11/11.
//

import Combine
import Foundation

class RawPageRepository: RawPageRepositoryProtocol {
    private let networkService: URLSessionNetworkServiceProtocol
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    
    init(networkService: URLSessionNetworkServiceProtocol, encoder: JSONEncoder, decoder: JSONDecoder) {
        self.networkService = networkService
        self.encoder = encoder
        self.decoder = decoder
    }
    
    func save(rawPage: RawPageEntity, at folder: String, with name: String) -> AnyPublisher<RawPageEntity, Error> {
        do {
            let data = try self.encoder.encode(rawPage)
            let request = FirebaseAPIs.uploadDataFile(folder, name, data)
            let publisher: AnyPublisher<[String:String], Error> = self.networkService.request(request)
            
            return publisher
                .map { _ in rawPage }
                .eraseToAnyPublisher()
        } catch(let error) {
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
    
    // FIXME: fetching api is not implemented
    func fetch(at folder: String, with name: String) -> AnyPublisher<RawPageEntity, Error> {
        return Just(RawPageEntity()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
}
