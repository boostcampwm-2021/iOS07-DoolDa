//
//  GeneratePairIdUseCaseProtocol.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/02.
//

import Combine
import Foundation

protocol GeneratePairIdUseCaseProtocol {
    func generatePairId(myId: String, friendId: String) -> AnyPublisher<String, Error>
}
