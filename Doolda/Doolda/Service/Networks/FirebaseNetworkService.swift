//
//  FirebaseNetworkService.swift
//  Doolda
//
//  Created by 정지승 on 2022/03/09.
//

import Combine
import Foundation

import Firebase

class FirebaseNetworkService: FirebaseNetworkServiceProtocol {
    enum Errors: LocalizedError {
        case invalidDocumentSnapshot
        case snapshotNotDecodable
        case dataUploadFailed
        case dataDownloadFailed
        
        var errorDescription: String? {
            switch self {
            case .invalidDocumentSnapshot: return "올바르지 않은 스냅샷입니다."
            case .snapshotNotDecodable: return "스냅샷 디코딩에 실패했습니다."
            case .dataUploadFailed: return "데이터 업로드에 실패했습니다."
            case .dataDownloadFailed: return "데이터 다운로드에 실패했습니다."
            }
        }
    }
    
    static let shared: FirebaseNetworkService = FirebaseNetworkService()
    
    private init() { }
     
    func getDocument(collection: FirebaseCollection, document: String) -> AnyPublisher<[String: Any], Error> {
        return Future { promise in
            Firestore.firestore().collection(collection.rawValue)
                .document(document)
                .getDocument { snapshot, error in
                    if let error = error { return promise(.failure(error)) }
                    guard let dictionary = snapshot?.data() else { return promise(.failure(Errors.invalidDocumentSnapshot)) }
                    return promise(.success(dictionary))
                }
        }
        .eraseToAnyPublisher()
    }
    
    func getDocument<T: DataTransferable>(collection: FirebaseCollection, document: String) -> AnyPublisher<T, Error> {
        return getDocument(collection: collection, document: document)
            .tryMap { dictionary in
                guard let decoded = T(dictionary: dictionary) else { throw Errors.snapshotNotDecodable }
                return decoded
            }
            .eraseToAnyPublisher()
    }
    
    func setDocument(collection: FirebaseCollection, document: String, dictionary: [String: Any]) -> AnyPublisher<Void, Error> {
        return Future { promise in
            Firestore.firestore().collection(collection.rawValue)
                .document(document)
                .setData(dictionary) { error in
                    if let error = error { return promise(.failure(error)) }
                    return promise(.success(()))
                }
        }
        .eraseToAnyPublisher()
    }
    
    func setDocument<T: DataTransferable>(collection: FirebaseCollection, document: String, transferable: T) -> AnyPublisher<Void, Error> {
        let dictionary = transferable.dictionary
        return setDocument(collection: collection, document: document, dictionary: dictionary)
    }
    
    func deleteDocument(collection: FirebaseCollection, document: String) -> AnyPublisher<Void, Error> {
        return Future { promise in
            Firestore.firestore().collection(collection.rawValue)
                .document(document)
                .delete { error in
                    if let error = error { return promise(.failure(error)) }
                    return promise(.success(()))
                }
        }
        .eraseToAnyPublisher()
    }
    
    func uploadData(path: String, fileName: String, data: Data) -> AnyPublisher<URL, Error> {
        let dataPath = "/\(path)/\(fileName)"
        let storage = Storage.storage().reference(withPath: dataPath)
        
        return Future<URL, Error> { promise in
            storage.putData(data, metadata: nil) { _, error in
                if let error = error { return promise(.failure(error)) }
                storage.downloadURL { url, error in
                    if let error = error { return promise(.failure(error)) }
                    guard let url = url else { return promise(.failure(Errors.dataUploadFailed)) }
                    return promise(.success(url))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func donwloadData(path: String, fileName: String) -> AnyPublisher<Data, Error> {
        let dataPath = "/\(path)/\(fileName)"
        let storage = Storage.storage().reference(withPath: dataPath)
        
        return Future<Data, Error> { promise in
            storage.getData(maxSize: 1024 * 1024 * 1024) { data, error in
                if let error = error { return promise(.failure(error)) }
                guard let data = data else {
                    return promise(.failure(Errors.dataDownloadFailed))
                }

                promise(.success(data))
            }
        }
        .eraseToAnyPublisher()
    }
}
