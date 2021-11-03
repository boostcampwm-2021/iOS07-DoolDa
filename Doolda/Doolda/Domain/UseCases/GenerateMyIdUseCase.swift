//
//  GenerateMyIdUseCase.swift
//  Doolda
//
//  Created by Seunghun Yang on 2021/11/04.
//

import Combine
import Foundation

protocol GenerateMyIdUseCaseProtocol {
    var savedIdPublisher: Published<String?>.Publisher { get }
    var errorPublisher: Published<Error?>.Publisher { get }
    
    func generate()
}

final class GenerateMyIdUseCase: GenerateMyIdUseCaseProtocol {
    private let userRepository: UserRepositoryProtocol
    
    private var cancellables: Set<AnyCancellable> = []
    @Published private var error: Error?
    @Published private var savedId: String?
    
    var savedIdPublisher: Published<String?>.Publisher { self.$savedId }
    var errorPublisher: Published<Error?>.Publisher { self.$error }
    
    init(userRepository: UserRepositoryProtocol) {
        self.userRepository = userRepository
    }
    
    func generate() {
        let myId = UUID().uuidString
        
        self.userRepository.checkUserIdIsExist(myId)
            .sink { [weak self] completion in
                guard case .failure(let error) = completion else { return }
                self?.error = error
            } receiveValue: { [weak self] _ in
                self?.save(myId)
            }
            .store(in: &cancellables)
    }
    
    private func save(_ id: String) {
        self.userRepository.saveMyId(id)
            .sink { [weak self] completion in
                guard case .failure(let error) = completion else { return }
                self?.error = error
            } receiveValue: { [weak self] _ in
                self?.savedId = id
            }
            .store(in: &cancellables)
    }
}

final class GenerateMyIdUseCase: GenerateMyIdUseCaseProtocol {
    func generateMyId() -> AnyPublisher<String, Error> {
        "".publisher.tryMap{_ in return ""}.eraseToAnyPublisher()
    }
}
