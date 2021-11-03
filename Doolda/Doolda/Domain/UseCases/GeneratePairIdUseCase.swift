//
//  GeneratePairIdUseCase.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/03.
//

import Combine
import Foundation

enum GeneratePairIdUseCaseError: LocalizedError {
    case invalidUserId
    case failedPairing
    
    var errorDescription: String? {
        switch self {
        case .invalidUserId:
            return "유효하지 않은 아이디입니다."
        case .failedPairing:
            return "친구맺기에 실패했습니다."
        }
    }
}

protocol GeneratePairIdUseCaseProtocol {
    var pairedIdPublisher: Published<String?>.Publisher { get }
    var errorPublisher: Published<Error?>.Publisher { get }
    func generatePairId(myId: String, friendId: String)
}

final class GeneratePairIdUseCase: GeneratePairIdUseCaseProtocol {
    var pairedIdPublisher: Published<String?>.Publisher { self.$pairedId }
    var errorPublisher: Published<Error?>.Publisher { self.$error }
    
    private let userRepository: UserRepositoryProtocol
    
    @Published private var pairedId: String?
    @Published private var error: Error?
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(userRepository: UserRepositoryProtocol) {
        self.userRepository = userRepository
    }
    
    func generatePairId(myId: String, friendId: String) {
        if myId == friendId {
            self.error = GeneratePairIdUseCaseError.failedPairing
        }
        
        self.userRepository.checkUserIdIsExist(friendId)
            .sink { [weak self] completion in
                guard case .failure(let error) = completion else { return }
                self?.error = error
            } receiveValue: { [weak self] result in
                if result {
                    self?.savePairId(myId: myId, friendId: friendId)
                } else {
                    self?.error = GeneratePairIdUseCaseError.invalidUserId
                }
            }
            .store(in: &self.cancellables)
    }
    
    private func savePairId(myId: String, friendId: String) {
        let pairId = UUID().uuidString
        
        self.userRepository.savePairId(myId: "", friendId: "", pairId: pairId)
            .sink { [weak self] completion in
                guard let self = self,
                      case .failure(let error) = completion else { return }
                self.error = error
                self.pairedId = nil
            } receiveValue: { [weak self] isSucceed in
                if isSucceed {
                    self?.pairedId = pairId
                }
            }
            .store(in: &self.cancellables)
    }
    
    private func isValidUUID(_ id: String) -> Bool {
        return id.range(of: "\\w{8}-\\w{4}-\\w{4}-\\w{4}-\\w{12}", options: .regularExpression) != nil
    }
}
