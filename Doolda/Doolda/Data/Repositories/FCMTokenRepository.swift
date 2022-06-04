//
//  FCMRepository.swift
//  Doolda
//
//  Created by Seunghun Yang on 2021/11/23.
//

import Combine
import Foundation

final class FCMTokenRepository: FCMTokenRepositoryProtocol {
    static let shared = FCMTokenRepository()
    
    private let firebaseNetworkService = FirebaseNetworkService.shared
    
    private var cancellables: Set<AnyCancellable> = []
    var tokenErrorHandler: ((Error?) -> Void)?
    @Published var currentFcmToken: String?
    @Published var currentUserDdid: DDID?
    
    private init() {
        self.bind()
    }
    
    private func bind() {
        Publishers.CombineLatest($currentFcmToken, $currentUserDdid)
            .sink { [weak self] token, ddid in
                guard let ddid = ddid,
                      let token = token else { return }
                self?.setToken(for: ddid, with: token)
            }
            .store(in: &cancellables)
    }
    
    private func setToken(for ddid: DDID, with token: String) {
        self.saveToken(for: ddid, with: token)
            .sink { [weak self] completion in
                guard case .failure(let error) = completion else { return }
                self?.tokenErrorHandler?(error)
            } receiveValue: { token in
                print("[FCMTokenUseCase] FCM Token updated for user \(ddid.ddidString) with token \(token)")
            }
            .store(in: &self.cancellables)
    }
    
    func saveToken(for userId: DDID, with token: String) -> AnyPublisher<String, Error> {
        let fcmToken = FCMToken(token: token)
        return firebaseNetworkService
            .setDocument(collection: .fcmToken, document: userId.ddidString, dictionary: fcmToken.dictionary)
            .map { token }
            .eraseToAnyPublisher()
    }
    
    func fetchToken(for userId: DDID) -> AnyPublisher<String, Error> {
        let publisher: AnyPublisher<FCMToken, Error> = firebaseNetworkService.getDocument(collection: .fcmToken, document: userId.ddidString)
        return publisher
            .map { $0.token }
            .eraseToAnyPublisher()
    }
}
