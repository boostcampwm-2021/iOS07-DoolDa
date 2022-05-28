//
//  SplashViewModel.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/01.
//

import Combine
import Foundation

import FirebaseAuth

protocol SplashViewModelInput {
    func validateAccount()
    func deinitRequested()
}

protocol SplashViewModelOutput {
    var errorPublisher: AnyPublisher<Error?, Never> { get }
}

typealias SplashViewModelProtocol = SplashViewModelInput & SplashViewModelOutput

final class SplashViewModel: SplashViewModelProtocol {
    var errorPublisher: AnyPublisher<Error?, Never> { self.$error.eraseToAnyPublisher() }
    @Published var error: Error?
    @Published private(set) var user: User?
    
    private let sceneId: UUID
    private let authenticateUseCase: AuthenticateUseCaseProtocol
    private let getMyIdUseCase: GetMyIdUseCaseProtocol
    private let getUserUseCase: GetUserUseCaseProtocol
    private let globalFontUseCase: GlobalFontUseCaseProtocol
    
    var loginPageRequested = PassthroughSubject<Void, Never>()
    var agreementPageRequested = PassthroughSubject<User, Never>()
    var pairingPageRequested = PassthroughSubject<User, Never>()
    var diaryPageRequested = PassthroughSubject<User, Never>()

    private var cancellables: Set<AnyCancellable> = []
    
    init(
        sceneId: UUID,
        authenticateUseCase: AuthenticateUseCaseProtocol,
        getMyIdUseCase: GetMyIdUseCaseProtocol,
        getUserUseCase: GetUserUseCaseProtocol,
        globalFontUseCase: GlobalFontUseCaseProtocol
    ) {
        self.sceneId = sceneId
        self.authenticateUseCase = authenticateUseCase
        self.getMyIdUseCase = getMyIdUseCase
        self.getUserUseCase = getUserUseCase
        self.globalFontUseCase = globalFontUseCase
        self.applyGlobalFont()
    }
    
    func deinitRequested() {
        NotificationCenter.default.post(
            name: BaseCoordinator.Notifications.coordinatorRemoveFromParent,
            object: nil,
            userInfo: [BaseCoordinator.Keys.sceneId: self.sceneId]
        )
    }
    
    /// get current firebase user using firebase auth.
    /// if firebase user is not exist, user need to login first
    /// if firebase user is exist, validate DDID using firebase user
    func validateAccount() {
        self.authenticateUseCase.getCurrentUser()
            .sink { [weak self] completion in
                guard case .failure(let error) = completion else { return }
                self?.error = error
            } receiveValue: { [weak self] firebaseUser in
                guard let firebaseUser = firebaseUser else {
                    self?.loginPageRequested.send()
                    return
                }
                self?.getIdAndValidate(with: firebaseUser)
            }
            .store(in: &cancellables)
    }
    
    private func validateUser(user: FirebaseAuth.User) {
        self.getMyIdUseCase.getMyId(for: user.uid)
            .compactMap { $0 }
            .flatMap { [weak self] ddid in
                return self?.getUserUseCase.getUser(for: ddid) ?? Empty<User, Error>(completeImmediately: true).eraseToAnyPublisher()
            }
            .sink { [weak self] completion in
                guard case .failure(let error) = completion else { return }
                self?.error = error
            } receiveValue: { [weak self] dooldaUser in
                self?.user = dooldaUser
                self?.validateUser(with: dooldaUser)
            }
            .store(in: &self.cancellables)
     }
    
    /// get doolda user using DDID and validate it.
    private func getUserAndValidate(with ddid: DDID) {
        self.getUserUseCase.getUser(for: ddid)
            .sink { completion in
                guard case .failure(let error) = completion else { return }
                self.error = error
            } receiveValue: { [weak self] dooldaUser in
                self?.validateUser(with: dooldaUser)
            }.store(in: &self.cancellables)
    }
    
    private func validateUser(with dooldaUser: User) {
        switch (dooldaUser.isAgreed, dooldaUser.isPaired) {
        case (false, _): self.agreementPageRequested.send(dooldaUser)
        case (true, false): self.pairingPageRequested.send(dooldaUser)
        case (true, true): self.diaryPageRequested.send(dooldaUser)
        }
    }

    private func applyGlobalFont() {
        guard let globalFont = self.globalFontUseCase.getGlobalFont() else { return }
        self.globalFontUseCase.setGlobalFont(with: globalFont.name)
    }
}
