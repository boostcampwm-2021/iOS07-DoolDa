//
//  API.swift
//  Doolda
//
//  Created by 김민주 on 2021/11/06.
//

import Foundation


enum FirebaseAPIs: URLRequestBuilder {
    case getUserDocuement
    case createUserDocument(String)
    case patchUserDocument(String, String, String)
    
    case getPairDocument(String)
    case createPairDocument(String, String)
    case patchPairDocument(String, String)
    case deletePairDocument(String)
    
    case getPageDocuments(String, Date?)
    case createPageDocument(String, Date, Date, String, String)
    case patchPageDocument(String, Date, Date, String, String)
    
    case getFCMTokenDocument(String)
    case patchFCMTokenDocument(String, String)

    case uploadDataFile(String, String, Data)
    case downloadDataFile(String, String)
    
    case sendFirebaseMessage(String, String, String, [String: Any])
}

extension FirebaseAPIs {
    var baseURL: URL? {
        switch self {
        case .uploadDataFile(let pairId, let fileName, _), .downloadDataFile(let pairId, let fileName):
            return URL(string: "https://firebasestorage.googleapis.com/v0/b/doolda.appspot.com/o/\(pairId)%2F\(fileName)")
        case .sendFirebaseMessage:
            return URL(string: "https://fcm.googleapis.com/fcm/send")
        default:
            return URL(string: "https://firestore.googleapis.com/v1/projects/doolda/databases/(default)/")
        }
    }
}

extension FirebaseAPIs {
    var path: String? {
        switch self {
        case .getUserDocuement, .patchUserDocument(_, _, _):
            guard let uid = AuthenticationService.shared.currentUser?.uid else { return nil }
            return "documents/user/\(uid)"
        case .createUserDocument:
            return "documents/user"
        case .getPairDocument(let pairId), .patchPairDocument(let pairId, _), .deletePairDocument(let pairId):
            return "documents/pair/\(pairId)"
        case .createPairDocument:
            return "documents/pair"
        case .getPageDocuments:
            return "documents:runQuery"
        case .createPageDocument:
            return "documents/page"
        case .patchPageDocument(_, _, _, let jsonPath, let pairId):
            return "documents/page/\(pairId + jsonPath)"
        case .getFCMTokenDocument(let userId), .patchFCMTokenDocument(let userId, _):
            return "documents/fcmToken/\(userId)"
        default: return nil
        }
    }
}

extension FirebaseAPIs {
    var parameters: [String : String]? {
        switch self {
        case .getUserDocuement,
             .getPairDocument,
             .getPageDocuments,
             .sendFirebaseMessage,
             .getFCMTokenDocument,
             .patchFCMTokenDocument,
             .deletePairDocument:
            return nil
        case .createUserDocument:
            guard let uid = AuthenticationService.shared.currentUser?.uid else { return nil }
            return ["documentId": uid]
        case .createPairDocument(let pairId, _):
            return ["documentId": pairId]
        case .createPageDocument(_, _, _, let jsonPath, let pairId):
            return ["documentId": pairId + jsonPath]
        case .patchUserDocument, .patchPairDocument, .patchPageDocument:
            return ["currentDocument.exists": "true"]
        case .uploadDataFile, .downloadDataFile:
            return ["alt": "media"]
        }
    }
}

extension FirebaseAPIs {
    var method: HttpMethod {
        switch self {
        case .getUserDocuement, .getPairDocument, .getFCMTokenDocument, .downloadDataFile:
            return .get
        case .createUserDocument, .createPairDocument, .createPageDocument, .uploadDataFile, .getPageDocuments, .sendFirebaseMessage:
            return .post
        case .patchUserDocument, .patchPairDocument, .patchPageDocument, .patchFCMTokenDocument:
            return .patch
        case .deletePairDocument:
            return .delete
        }
    }
}

extension FirebaseAPIs {
    var headers: [String : String]? {
        switch self {
        case .downloadDataFile:
            return nil
        case .uploadDataFile:
            return ["Content-Type": "application/octet-stream"]
        case .sendFirebaseMessage:
            return ["Content-Type": "application/json", "Authorization": "key=\(Secrets.fcmServerKey ?? "")"]
        default :
            return ["Content-Type": "application/json", "Accept": "application/json", "Authorization": "Bearer \(Secrets.idToken ?? "")"]
        }
    }
}

extension FirebaseAPIs {
    var body: [String: Any]? {
        switch self {
        case .getUserDocuement, .getPairDocument, .getFCMTokenDocument, .uploadDataFile, .downloadDataFile, .deletePairDocument:
            return nil
        case .getPageDocuments(let pairId, let date):
            var filters = [[String: Any]]()
            filters.append(
                generateFieldFilter(
                    field: "pairId",
                    operation: "EQUAL",
                    filter: ["stringValue": pairId]
                )
            )
            
            if let date = date {
                filters.append(
                    generateFieldFilter(
                        field: "createdTime",
                        operation: "GREATER_THAN",
                        filter: ["timestampValue": DateFormatter.firestoreFormatter.string(from: date)]
                    )
                )
            }
            
            return [
                "structuredQuery": [
                    "from": [
                        [
                            "collectionId": "page",
                            "allDescendants": true
                        ]
                    ],
                    "where": [
                        "compositeFilter": [
                            "op": "AND",
                            "filters": filters
                        ]
                    ],
                    "orderBy": [
                        "field": [
                            "fieldPath": "createdTime"
                        ],
                        "direction": "DESCENDING"
                    ]
                ]
            ]
        case .createUserDocument(let userId):
            guard let uid = AuthenticationService.shared.currentUser?.uid else { return nil }
            let userDocument = UserDocument(uid: uid, userId: userId, pairId: "", friendId: "")
            return [
                "fields": userDocument.fields
            ]
        case .patchUserDocument(let userId, let pairId, let friendId):
            guard let uid = AuthenticationService.shared.currentUser?.uid else { return nil }
            let userDocument = UserDocument(uid: uid, userId: userId, pairId: pairId, friendId: friendId)
            return [
                "fields": userDocument.fields
            ]
        case .createPairDocument(let pairId, let recentlyEditedUser), .patchPairDocument(let pairId, let recentlyEditedUser):
            let pairDocument = PairDocument(pairId: pairId, recentlyEditedUser: recentlyEditedUser)
            return [
                "fields": pairDocument.fields
            ]
        case .createPageDocument(let authorId, let createdTime, let updatedTime, let jsonPath, let pairId),
             .patchPageDocument(let authorId, let createdTime, let updatedTime, let jsonPath, let pairId):
            let pageDocument = PageDocument(
                author: authorId,
                createdTime: createdTime,
                updatedTime: updatedTime,
                jsonPath: jsonPath,
                pairId: pairId
            )
            return [
                "fields": pageDocument.fields
            ]
        case .sendFirebaseMessage(let receiverToken, let title, let body, let data):
            return [
                "to": receiverToken,
                "notification": [
                    "title": title,
                    "body": body,
                    "mutable_content": true,
                    "sound": "Tri-tone"
                ],
                "data": data
            ]
        case .patchFCMTokenDocument(_, let token):
            let tokenDocument = FCMTokenDocument(token: token)
            return [
                "fields": tokenDocument.fields
            ]
        }
    }
    
    func generateFieldFilter(field: String, operation: String, filter: [String: Any]) -> [String: Any] {
        return [
            "fieldFilter": [
                "field": [
                    "fieldPath": field
                ],
                "op": operation,
                "value": filter
            ]
        ]
    }
}

extension FirebaseAPIs {
    var binary: Data? {
        switch self {
        case .uploadDataFile(_, _, let data):
            return data
        default:
            return nil
        }
    }
}
