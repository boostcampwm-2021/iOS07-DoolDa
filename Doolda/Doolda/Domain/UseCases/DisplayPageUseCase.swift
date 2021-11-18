//
//  DisplayPageUseCase.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/18.
//

import Combine
import Foundation

protocol DisplayPageUseCaseProtocol {
    func getRawPageEntity(for pairId: DDID, jsonPath: String) -> AnyPublisher<RawPageEntity, Error>
}
