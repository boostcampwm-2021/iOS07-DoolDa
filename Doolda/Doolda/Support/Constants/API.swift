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

    case uploadDataFile(String, String, Data)
}

extension FirebaseAPIs {
    var baseURL: URL? {
        switch self {
        case .uploadDataFile(let pairId, let fileName, _):
            return URL(string: "https://firebasestorage.googleapis.com/v0/b/doolda.appspot.com/o/\(pairId)%2F\(fileName)")
        default:
            return URL(string: "https://firestore.googleapis.com/v1/projects/doolda/databases/(default)/")
        }
    }
    var storage: URL? {
        return URL(string: "https://firebasestorage.googleapis.com/v0/b/doolda.appspot.com/o/")
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
        default: return nil
        }
    }
}

extension FirebaseAPIs {
    var parameters: [String : String]? {
        switch self {
        case .getUserDocuement, .getPairDocument:
            return nil
        case .createUserDocument(let id), .createPairDocument(let id, _):
            return ["documentId": id]
        case .patchUserDocuement, .patchPairDocument:
            return ["currentDocument.exists": "true"]
        case .uploadDataFile:
            return ["alt": "media"]
        }
    }
}

extension FirebaseAPIs {
    var method: HttpMethod {
        switch self {
        case .getUserDocuement, .getPairDocument:
            return .get
        case .createUserDocument, .createPairDocument, .uploadDataFile:
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
        case .getUserDocuement, .getPairDocument, .uploadDataFile:
            return nil
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
        }
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
