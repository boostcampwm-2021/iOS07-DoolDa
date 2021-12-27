//
//  GetMyIdUseCaseProtocol.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/29.
//

import Combine
import Foundation

protocol GetMyIdUseCaseProtocol {
    // FIXME: Deprecated
    func getMyId() -> AnyPublisher<DDID?, Never>
    
    func getMyId(for uid: String) -> AnyPublisher<DDID?, Never>
}
