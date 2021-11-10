//
//  FileManagerPersistenceServiceProtocol.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/09.
//

import Combine
import Foundation

protocol FileManagerPersistenceServiceProtocol {
    func save(data: Data, at documentsUrl: URL, fileName: String) -> AnyPublisher<Data, Error>
}

//class temp {
//    func test() {
//        let data: Data = Data()
//        let t = NSData(data: data)
//        let object = NSObject()
//        
//        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//        let url2 = FileManager.default.temporaryDirectory
//    }
//}
