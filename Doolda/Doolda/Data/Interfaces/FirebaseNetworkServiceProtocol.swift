//
//  FirebaseNetworkServiceProtocol.swift
//  Doolda
//
//  Created by 정지승 on 2022/03/09.
//

import Combine
import Foundation

protocol FirebaseNetworkServiceProtocol {
    func getDocument(collection: FirebaseCollection, document: String) -> AnyPublisher<[String: Any], Error>
    func setDocument(collection: FirebaseCollection, document: String, dictionary: [String: Any]) -> AnyPublisher<Void, Error>
    func getDocument<T: DataTransferable>(collection: FirebaseCollection, document: String) -> AnyPublisher<T, Error>
    func setDocument<T: DataTransferable>(collection: FirebaseCollection, document: String, transferable: T) -> AnyPublisher<Void, Error>
    func deleteDocument(collection: FirebaseCollection, document: String) -> AnyPublisher<Void, Error>
    func uploadData(path: String, fileName: String, data: Data) -> AnyPublisher<URL, Error>
    func donwloadData(path: String, fileName: String) -> AnyPublisher<Data, Error>
}

protocol DataTransferable {
    init?(dictionary: [String: Any])
    var dictionary: [String: Any] { get }
}
