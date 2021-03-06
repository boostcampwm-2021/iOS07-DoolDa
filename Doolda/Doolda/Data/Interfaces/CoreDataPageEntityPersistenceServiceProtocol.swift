//
//  CoreDataPageEntityPersistenceServiceProtocol.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/17.
//

import Combine
import Foundation

protocol CoreDataPageEntityPersistenceServiceProtocol {
    func isPageEntityUpToDate(_ pageEntity: PageEntity) -> AnyPublisher<Bool, Error>
    func fetchPageEntities() -> AnyPublisher<[PageEntity], Error>
    func savePageEntity(_ pageEntity: PageEntity) -> AnyPublisher<PageEntity, Error>
    func removeAllPageEntity() -> AnyPublisher<Void, Error>
}
