//
//  GetMyIdUseCaseProtocol.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/29.
//

import Combine
import Foundation

protocol GetMyIdUseCaseProtocol {
    @available(*, deprecated, message: "getMyId(for uid: String) -> AnyPublisher<DDID?, Never>를 사용하세요")
    func getMyId() -> AnyPublisher<DDID?, Never>
    
    func getMyId(for uid: String) -> AnyPublisher<DDID?, Error>
}
