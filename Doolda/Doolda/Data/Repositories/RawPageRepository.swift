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
    
    init(networkService: URLSessionNetworkServiceProtocol, encoder: JSONEncoder = JSONEncoder()) {
        self.networkService = networkService
        self.encoder = encoder
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
    
    func fetch(at folder: String, with name: String) -> AnyPublisher<RawPageEntity, Error> {
        let request = FirebaseAPIs.downloadDataFile(folder, name)
        return self.networkService.request(request)
            .eraseToAnyPublisher()
    }
}
