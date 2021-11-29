//
//  CheckMyTurnUseCaseProtocol.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/29.
//

import Combine
import Foundation

protocol CheckMyTurnUseCaseProtocol {
    func checkTurn(for user: User) -> AnyPublisher<Bool, Error>
}
