//
//  API.swift
//  Doolda
//
//  Created by 김민주 on 2021/11/06.
//

import Foundation

enum FirebaseAPIs: URLRequestBuilder {
    case getUserDocuement(String)
    case createUserDocument(String)
    case patchUserDocuement(String, String)
    
    case getPairDocument(String)
    case createPairDocument(String, String)
    case patchPairDocument(String, String)
    
    case createPageDocument(String, Date, String, String)
    case getPageDocuments(String, Date?)

    case uploadDataFile(String, String, Data)
    case downloadDataFile(String, String)
}

extension FirebaseAPIs {
    var baseURL: URL? {
        switch self {
        case .uploadDataFile(let pairId, let fileName, _), .downloadDataFile(let pairId, let fileName):
            return URL(string: "https://firebasestorage.googleapis.com/v0/b/doolda.appspot.com/o/\(pairId)%2F\(fileName)")
        default:
            return URL(string: "https://firestore.googleapis.com/v1/projects/doolda/databases/(default)/")
        }
    }
}

extension FirebaseAPIs {
    var path: String? {
        switch self {
        case .getUserDocuement(let userId), .patchUserDocuement(let userId, _):
            return "documents/user/\(userId)"
        case .createUserDocument:
            return "documents/user"
        case .getPairDocument(let pairId), .patchPairDocument(let pairId, _):
            return "documents/pair/\(pairId)"
        case .createPairDocument:
            return "documents/pair"
        case .getPageDocuments:
            return "documents:runQuery"
        case .createPageDocument:
            return "documents/page"
        default: return nil
        }
    }
}

extension FirebaseAPIs {
    var parameters: [String : String]? {
        switch self {
        case .getUserDocuement, .getPairDocument, .getPageDocuments:
            return nil
        case .createUserDocument(let id), .createPairDocument(let id, _):
            return ["documentId": id]
        case .createPageDocument(_, _, let jsonPath, let pairId):
            return ["documentId": pairId + jsonPath]
        case .patchUserDocuement, .patchPairDocument:
            return ["currentDocument.exists": "true"]
        case .uploadDataFile, .downloadDataFile:
            return ["alt": "media"]
        }
    }
}

extension FirebaseAPIs {
    var method: HttpMethod {
        switch self {
        case .getUserDocuement, .getPairDocument, .downloadDataFile:
            return .get
        case .createUserDocument, .createPairDocument, .createPageDocument, .uploadDataFile, .getPageDocuments:
            return .post
        case .patchUserDocuement, .patchPairDocument:
            return .patch
        }
    }
}

extension FirebaseAPIs {
    var headers: [String : String]? {
        switch self {
        case .uploadDataFile:
            return ["Content-Type": "application/octet-stream"]
        default :
            return ["Content-Type": "application/json", "Accept": "application/json"]
        }
    }
}

extension FirebaseAPIs {
    var body: [String: Any]? {
        switch self {
        case .getUserDocuement, .getPairDocument, .uploadDataFile, .downloadDataFile:
            return nil
        case .getPageDocuments(let pairId, let lastFetchedDate):
            var filters = [[String: Any?]]()
            filters.append(
                generateFieldFilter(
                    field: "pairId",
                    operation: "EQUAL",
                    filter: ["stringValue": pairId]
                )
            )
            
            if let lastFetchedDate = lastFetchedDate {
                filters.append(
                    generateFieldFilter(
                        field: "createdTime",
                        operation: "GREATER_THAN_OR_EQUAL",
                        filter: ["timestampValue": lastFetchedDate]
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
                        [
                            "compositeFilter": [
                                "op": "AND",
                                "filters": filters
                            ]
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
            let userDocument = UserDocument(userId: userId, pairId: "")
            return [
                "fields": userDocument.fields
            ]
        case .patchUserDocuement(let userId, let pairId):
            let userDocument = UserDocument(userId: userId, pairId: pairId)
            return [
                "fields": userDocument.fields
            ]
        case .createPairDocument(let pairId, let recentlyEditedUser), .patchPairDocument(let pairId, let recentlyEditedUser):
            let pairDocument = PairDocument(pairId: pairId, recentlyEditedUser: recentlyEditedUser)
            return [
                "fields": pairDocument.fields
            ]
        case .createPageDocument(let authorId, let createdTime, let jsonPath, let pairId):
            let pageDocument = PageDocument(author: authorId, createdTime: createdTime, jsonPath: jsonPath, pairId: pairId)
            return [
                "fields": pageDocument.fields
            ]
        }
    }
    
    func generateFieldFilter(field: String, operation: String, filter: [String: Any?]) -> [String: Any?] {
        return [
            "fieldFilter": [
                "field": [
                    "fieldPath": field
                ],
                "op": operation,
                "value": [
                    filter
                ]
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
