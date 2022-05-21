//
//  GetMyIdUsecase.swift
//  Doolda
//
//  Created by 김민주 on 2021/11/02.
//

import Combine
import Foundation

final class GetMyIdUseCase: GetMyIdUseCaseProtocol {
    private let userRepository: UserRepositoryProtocol
        
    init(userRepository: UserRepositoryProtocol) {
        self.userRepository = userRepository
    }
    
    func getMyId() -> AnyPublisher<DDID?, Never> {
        return userRepository.getMyId()
    }
    
    // TODO: [승지] uid로 DDID 가져오도록 바꾸기 (repository도 포함)
    // uid 에 대응되는 DDID를 올리는건 Dozzing이 한다.
    func getMyId(for uid: String) -> AnyPublisher<DDID?, Error> {
        return self.userRepository.getMyId(for: uid)
    }
}
