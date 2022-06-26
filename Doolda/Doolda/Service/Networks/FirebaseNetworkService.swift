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
        case requestTimeOut
        
        var errorDescription: String? {
            switch self {
            case .invalidDocumentSnapshot: return "올바르지 않은 스냅샷"
            case .snapshotNotDecodable: return "스냅샷 디코딩 실패"
            case .dataUploadFailed: return "데이터 업로드에 실패"
            case .dataDownloadFailed: return "데이터 다운로드에 실패"
            case .requestTimeOut: return "요청 시간 초과"
            }
        }
    }
    
    static let shared: FirebaseNetworkService = FirebaseNetworkService()
    static let timeOutLimit: Int = 60
    
    private let firestore = Firestore.firestore()
    private let scheduler = DispatchQueue.global()
    private var cancellables: Set<AnyCancellable> = []
    
    private init() { }
     
    func getDocument(collection: FirebaseCollection, document: String) -> AnyPublisher<[String: Any], Error> {
        return Future { [weak self] promise in
            self?.firestore.collection(collection.rawValue)
                .document(document)
                .getDocument { snapshot, error in
                    if let error = error { return promise(.failure(error)) }
                    guard let dictionary = snapshot?.data() else { return promise(.failure(Errors.invalidDocumentSnapshot)) }
                    return promise(.success(dictionary))
                }
        }
        .timeout(.seconds(Self.timeOutLimit), scheduler: scheduler, customError: { Errors.requestTimeOut })
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
    
    func getDocuments(collection: FirebaseCollection, conditions: [String: Any]?) -> AnyPublisher<[[String: Any]], Error> {
        var pageSearchQuery: Query = self.firestore.collection(collection.rawValue)
        
        conditions?.forEach { field, condition in
            pageSearchQuery = pageSearchQuery.whereField(field, isEqualTo: condition)
        }
        
        return Future { promise in
            pageSearchQuery.getDocuments { snapshot, error in
                if let error = error { return promise(.failure(error)) }
                if let dictionaries = snapshot?.documents.map({ queryDocumentSnapshot in queryDocumentSnapshot.data() }) {
                    return promise(.success(dictionaries))
                } else {
                    return promise(.failure(Errors.invalidDocumentSnapshot))
                }
            }
        }
        .timeout(.seconds(Self.timeOutLimit), scheduler: scheduler, customError: { Errors.requestTimeOut })
        .eraseToAnyPublisher()
    }
    
    func getDocuments<T: DataTransferable>(collection: FirebaseCollection, conditions: [String: Any]?) -> AnyPublisher<[T], Error> {
        return getDocuments(collection: collection, conditions: conditions)
            .tryMap { dictionaries in
                var result: [T] = []
                for dictionary in dictionaries {
                    guard let decoded = T(dictionary: dictionary) else { throw Errors.snapshotNotDecodable }
                    result.append(decoded)
                }
                return result
            }
            .eraseToAnyPublisher()
    }
    
    func setDocument(collection: FirebaseCollection, document: String, dictionary: [String: Any]) -> AnyPublisher<Void, Error> {
        return Future { [weak self] promise in
            self?.firestore.collection(collection.rawValue)
                .document(document)
                .setData(dictionary) { error in
                    if let error = error { return promise(.failure(error)) }
                    return promise(.success(()))
                }
        }
        .timeout(.seconds(Self.timeOutLimit), scheduler: scheduler, customError: { Errors.requestTimeOut })
        .eraseToAnyPublisher()
    }
    
    func setDocument<T: DataTransferable>(collection: FirebaseCollection, document: String, transferable: T) -> AnyPublisher<Void, Error> {
        let dictionary = transferable.dictionary
        return setDocument(collection: collection, document: document, dictionary: dictionary)
    }
    
    func deleteDocument(collection: FirebaseCollection, document: String) -> AnyPublisher<Void, Error> {
        return Future { [weak self] promise in
            self?.firestore.collection(collection.rawValue)
                .document(document)
                .delete { error in
                    if let error = error { return promise(.failure(error)) }
                    return promise(.success(()))
                }
        }
        .timeout(.seconds(Self.timeOutLimit), scheduler: scheduler, customError: { Errors.requestTimeOut })
        .eraseToAnyPublisher()
    }
    
    func deleteDocuments(collection: FirebaseCollection, fieldPath: FieldPath, prefix: String) -> AnyPublisher<Void, Error> {
        let query = Firestore.firestore().collection(collection.rawValue)
            .whereField(fieldPath, isGreaterThanOrEqualTo: prefix)
            .whereField(fieldPath, isLessThan: prefix + "z")
        
        return Future { promise in
            query.getDocuments { snapshot, error in
                if let error = error { return promise(.failure(error)) }
                guard let snapshot = snapshot else { return promise(.failure(Errors.invalidDocumentSnapshot)) }
                let batch = Firestore.firestore().batch()
                
                snapshot.documents.forEach { batch.deleteDocument($0.reference) }
                
                batch.commit { error in
                    if let error = error { return promise(.failure(error)) }
                    promise(.success(()))
                }
            }
        }
        .timeout(.seconds(Self.timeOutLimit), scheduler: scheduler, customError: { Errors.requestTimeOut })
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
        .timeout(.seconds(Self.timeOutLimit), scheduler: scheduler, customError: { Errors.requestTimeOut })
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
        .timeout(.seconds(Self.timeOutLimit), scheduler: scheduler, customError: { Errors.requestTimeOut })
        .eraseToAnyPublisher()
    }
    
    func deleteStorageFolder(path: String) -> AnyPublisher<Void, Error> {
        let storage = Storage.storage().reference(withPath: path)
        
        return Future { [weak self] promise in
            guard let self = self else { return }
            
            storage.listAll { storageList, error in
                if let error = error { return promise(.failure(error)) }

                Publishers.MergeMany(storageList.items.map { $0.delete() })
                    .collect()
                    .sink { completion in
                        guard case .failure(let error) = completion else { return }
                        promise(.failure(error))
                    } receiveValue: { _ in
                        promise(.success(()))
                    }
                    .store(in: &self.cancellables)
            }
        }
        .timeout(.seconds(Self.timeOutLimit), scheduler: scheduler, customError: { Errors.requestTimeOut })
        .eraseToAnyPublisher()
    }
    
    func observeDocument(collection: FirebaseCollection, document: String) -> AnyPublisher<[String: Any], Error> {
        let subject = PassthroughSubject<[String: Any], Error>()
        
        self.firestore.collection(collection.rawValue)
            .document(document)
            .addSnapshotListener { snapshot, error in
                if let error = error { return subject.send(completion: .failure(error)) }
                guard let dictionary = snapshot?.data() else { return subject.send(completion: .failure(Errors.invalidDocumentSnapshot)) }
                subject.send(dictionary)
            }
        
        return subject.eraseToAnyPublisher()
    }
    
    func observeDocument<T: DataTransferable>(collection: FirebaseCollection, document: String) -> AnyPublisher<T, Error> {
        return observeDocument(collection: collection, document: document)
            .tryMap { dictionary in
                guard let decoded = T(dictionary: dictionary) else { throw Errors.snapshotNotDecodable }
                return decoded
            }
            .eraseToAnyPublisher()
    }
}
