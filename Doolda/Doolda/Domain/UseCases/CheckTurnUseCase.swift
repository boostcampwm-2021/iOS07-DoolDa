//
//  CheckTurnUseCase.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/16.
//

import Combine
import Foundation

protocol CheckTurnUseCaseProtocol {
    func checkTurn(for user: User) -> AnyPublisher<Bool, Error>
}

class CheckTurnUseCase: CheckTurnUseCaseProtocol {
    func checkTurn(for user: User) -> AnyPublisher<Bool, Error> {
        // FIXME: not implemented
        return Just(true).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
}
