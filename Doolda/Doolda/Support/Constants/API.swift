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
}

extension FirebaseAPIs {
    var baseURL: URL? {
        switch self {
        case .getUserDocuement, .createUserDocument:
            return URL(string: "https://firestore.googleapis.com/v1/projects/doolda/databases/(default)/")
        }
    }
}

extension FirebaseAPIs {
    var path: String {
        switch self {
        case .getUserDocuement(let userId):
            return "documents/user/\(userId)"
        case .createUserDocument:
            return "documents/user"
        }
    }
}

extension FirebaseAPIs {
    var parameters: [String : String]? {
        switch self {
        case .getUserDocuement:
            return nil
        case .createUserDocument(let userId):
            return ["documentId": userId]
        }
    }
}

extension FirebaseAPIs {
    var method: HttpMethod {
        switch self {
        case .getUserDocuement:
            return .get
        case .createUserDocument:
            return .post
        }
    }
}

extension FirebaseAPIs {
    var body: [String: Any]? {
        switch self {
        case .getUserDocuement:
            return nil
        case .createUserDocument:
            return [
                "fields": [
                    "pairId": [
                        "stringValue": ""
                    ]
                ]
            ]
        }
    }
}
