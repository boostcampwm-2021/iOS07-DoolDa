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
    
    private let sceneId: UUID
    private let authenticationUseCase: AuthenticationUseCaseProtocol
    private let getMyIdUseCase: GetMyIdUseCaseProtocol
    private let getUserUseCase: GetUserUseCaseProtocol
    private let globalFontUseCase: GlobalFontUseCaseProtocol

    private var cancellables: Set<AnyCancellable> = []
    @Published private var error: Error?
    
    init(
        sceneId: UUID,
        authenticationUseCase: AuthenticationUseCaseProtocol,
        getMyIdUseCase: GetMyIdUseCaseProtocol,
        getUserUseCase: GetUserUseCaseProtocol,
        globalFontUseCase: GlobalFontUseCaseProtocol
    ) {
        self.sceneId = sceneId
        self.authenticationUseCase = authenticationUseCase
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
    
    func validateAccount() {
        if let currentUser = self.authenticationUseCase.getCurrentUser() {
            self.validateUserId(user: currentUser)
        } else {
            NotificationCenter.default.post(
                name: SplashViewCoordinator.Notifications.userNotLoggedIn,
                object: self
            )
        }
    }
    
    private func validateUserId(user: FirebaseAuth.User) {
        self.getMyIdUseCase.getMyId(for: user.uid)
            .sink { [weak self] ddid in
                if let userId = ddid {
                    self?.validateAgreement(userId: userId)
                } else {
                    NotificationCenter.default.post(
                        name: SplashViewCoordinator.Notifications.userNotExists,
                        object: self
                    )
                }
            }
            .store(in: &self.cancellables)
    }
    
    private func validateAgreement(userId: DDID) {
        self.getUserUseCase.getUser(for: userId)
            .sink { completion in
                guard case .failure(let error) = completion else { return }
                // TODO: - error를 식별해 처리해야함.
                print(error)
                NotificationCenter.default.post(
                    name: SplashViewCoordinator.Notifications.userNotExists,
                    object: self
                )
                self.error = error
            } receiveValue: { user in
                if user.pairId?.ddidString.isEmpty == false {
                    NotificationCenter.default.post(
                        name: SplashViewCoordinator.Notifications.userAlreadyPaired,
                        object: self,
                        userInfo: [SplashViewCoordinator.Keys.user: user]
                    )
                } else {
                    NotificationCenter.default.post(
                        name: SplashViewCoordinator.Notifications.userNotPaired,
                        object: self,
                        userInfo: [SplashViewCoordinator.Keys.myId: user.id]
                    )
                }
            }
            .store(in: &self.cancellables)
    }

    private func applyGlobalFont() {
        guard let globalFont = self.globalFontUseCase.getGlobalFont() else { return }
        self.globalFontUseCase.setGlobalFont(with: globalFont.name)
    }
}
