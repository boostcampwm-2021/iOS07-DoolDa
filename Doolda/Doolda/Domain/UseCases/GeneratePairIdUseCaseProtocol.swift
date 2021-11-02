//
//  GeneratePairIdUseCaseProtocol.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/02.
//

import Foundation
import Combine

protocol GeneratePairIdUseCaseProtocol {
    func checkIfUserIdExist(id: UUID) -> AnyPublisher<Bool, Error>
    func generatePairId(myId: UUID, friendId: UUID) -> AnyPublisher<UUID, Error>
}
