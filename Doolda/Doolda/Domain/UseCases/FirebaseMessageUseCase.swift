//
//  FirebaseMessageUseCase.swift
//  Doolda
//
//  Created by Seunghun Yang on 2021/11/23.
//

import Combine
import Foundation

protocol FirebaseMessageUseCaseProtocol {
    var errorPublisher: Published<Error?>.Publisher { get }
    var isMessageSentPublisher: Published<Bool?>.Publisher { get }
    
    func sendMessage(to user: DDID, title: String, body: String, data: [String : String])
}

class FirebaseMessageUseCase: FirebaseMessageUseCaseProtocol {
    var errorPublisher: Published<Error?>.Publisher { self.$error }
    var isMessageSentPublisher: Published<Bool?>.Publisher { self.$isMessageSent }
    
    private let fcmTokenRepository: FCMTokenRepositoryProtocol
    private let firebaseMessageRepository: FirebaseMessageRepositoryProtocol
    
    private var cancellables: Set<AnyCancellable> = []
    
    @Published private var error: Error?
    @Published private var isMessageSent: Bool?
    
    init(fcmTokenRepository: FCMTokenRepositoryProtocol, firebaseMessageRepository: FirebaseMessageRepositoryProtocol) {
        self.fcmTokenRepository = fcmTokenRepository
        self.firebaseMessageRepository = firebaseMessageRepository
    }
    
    func sendMessage(to user: DDID, title: String, body: String, data: [String : String]) {
        self.fcmTokenRepository.fetchToken(for: user)
            .sink { [weak self] completion in
                guard case .failure(let error) = completion else { return }
                self?.error = error
            } receiveValue: { [weak self] token in
                guard let self = self else { return }
                self.firebaseMessageRepository.sendMessage(to: token, title: title, body: body, data: data)
                    .sink { [weak self] completion in
                        guard case .failure(let error) = completion else { return }
                        self?.error = error
                    } receiveValue: { [weak self] _ in
                        self?.isMessageSent = true
                    }
                    .store(in: &self.cancellables)
            }
            .store(in: &self.cancellables)
    }
}
