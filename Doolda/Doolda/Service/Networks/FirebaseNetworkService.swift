//
//  FirebaseNetworkService.swift
//  Doolda
//
//  Created by 김민주 on 2021/11/02.
//
import Combine
import Foundation

import FirebaseCore
import FirebaseFirestore

class FirebaseNetworkService: FirebaseNetworkProtocol {
    enum Errors: Error, LocalizedError {
        case nilResultError
        
        var errorDescription: String? {
            switch self {
            case .nilResultError:
                return "값이 존재하지 않습니다"
            }
        }
    }
    
    func setDocument(path: String? = nil, in collection: String, with data: [String: Any]) -> AnyPublisher<Bool, Error> {
        let database = Firestore.firestore()
        
        if let path = path {
            
            let documentReference = database.collection(collection).document(path)
            
            return Future<Bool, Error> { promise in
                documentReference.setData(data) { error in
                    if let error = error {
                        promise(.failure(error))
                    } else {
                        promise(.success(true))
                    }
                }
            }.eraseToAnyPublisher()
        } else {
            
            let randomDocumentReference = database.collection(collection).document()
            
            return Future<Bool, Error> { promise in
                randomDocumentReference.setData(data) { error in
                    if let error = error {
                        promise(.failure(error))
                    } else {
                        promise(.success(true))
                    }
                }
            }.eraseToAnyPublisher()
        }
    }

    func getDocument(path: String, in collection: String) -> AnyPublisher<FirebaseDocument, Error> {
        let database = Firestore.firestore()
        let documentReference: DocumentReference = database.collection(collection).document(path)
        
        return Future<FirebaseDocument,Error> { promise in
            documentReference.getDocument { documentSnapshot, error in
                if let error = error {
                    promise(.failure(error))
                } else if let documentData = documentSnapshot?.data() {
                    promise(.success(FirebaseDocument(data: documentData)))
                } else {
                    promise(.failure(Errors.nilResultError))
                }
            }
        }.eraseToAnyPublisher()
    }
}
