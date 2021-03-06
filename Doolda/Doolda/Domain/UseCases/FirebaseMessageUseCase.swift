//
//  FirebaseMessageUseCase.swift
//  Doolda
//
//  Created by Seunghun Yang on 2021/11/23.
//

import Combine
import Foundation

final class FirebaseMessageUseCase: FirebaseMessageUseCaseProtocol {
    var errorPublisher: AnyPublisher<Error?, Never> { self.$error.eraseToAnyPublisher() }
    
    private let fcmTokenRepository: FCMTokenRepositoryProtocol
    private let firebaseMessageRepository: FirebaseMessageRepositoryProtocol
    
    private var cancellables: Set<AnyCancellable> = []
    
    @Published private var error: Error?
    
    static let `default` = FirebaseMessageUseCase(
        fcmTokenRepository: FCMTokenRepository.shared,
        firebaseMessageRepository: FirebaseMessageRepository(urlSessionNetworkService: URLSessionNetworkService.shared)
    )
    
    init(fcmTokenRepository: FCMTokenRepositoryProtocol, firebaseMessageRepository: FirebaseMessageRepositoryProtocol) {
        self.fcmTokenRepository = fcmTokenRepository
        self.firebaseMessageRepository = firebaseMessageRepository
    }
    
    func sendMessage(to user: DDID, message: PushMessageEntity) {
        self.fcmTokenRepository.fetchToken(for: user)
            .sink { [weak self] completion in
                guard case .failure(let error) = completion else { return }
                self?.error = error
            } receiveValue: { [weak self] token in
                guard let self = self else { return }
                self.firebaseMessageRepository.sendMessage(
                    to: token,
                    title: message.title,
                    body: message.body,
                    data: message.data
                )
                    .sink { [weak self] completion in
                        guard case .failure(let error) = completion else { return }
                        self?.error = error
                    } receiveValue: { _ in }
                    .store(in: &self.cancellables)
            }
            .store(in: &self.cancellables)
    }
}
