//
//  FirebaseNetworkService.swift
//  Doolda
//
//  Created by 김민주 on 2021/11/02.
//

import Foundation

import Combine
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
    
    func getDocument(path: String, in collection: String) -> AnyPublisher<[String: Any], Error> {
        let database = Firestore.firestore()
        let documentReference: DocumentReference = database.collection(collection).document(path)
        
        return Future<[String: Any],Error> { promise in
            documentReference.getDocument { documentSnapshot, error in
                if let error = error {
                    promise(.failure(error))
                } else if let documentData = documentSnapshot?.data() {
                    promise(.success(documentData))
                } else {
                    promise(.failure(Errors.nilResultError))
                }
            }
        }.eraseToAnyPublisher()
    }
}
