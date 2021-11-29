//
//  GetRawPageUseCaseProtocol.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/29.
//

import Combine
import Foundation

protocol GetRawPageUseCaseProtocol {
    func getRawPageEntity(metaData: PageEntity) -> AnyPublisher<RawPageEntity, Error>
}
