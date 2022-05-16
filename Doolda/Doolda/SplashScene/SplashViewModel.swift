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
    var agreementPageRequested = PassthroughSubject<Void, Never>()
    var pairingPageRequested = PassthroughSubject<DDID, Never>()
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
    
    func validateAccount() {
        if let currentUser = self.authenticateUseCase.getCurrentUser() {
            self.validateUser(user: currentUser)
        } else {
            self.loginPageRequested.send()
        }
    }
    
    private func validateUser(user: FirebaseAuth.User) {
         self.getMyIdUseCase.getMyId(for: user.uid)
             .sink { [weak self] ddid in
                 guard let self = self else { return }
                 guard let ddid = ddid else { return } // 에러 처리
                 self.getUserUseCase.getUser(for: ddid)
                     .sink { completion in
                         guard case .failure(let error) = completion else { return }
                         self.error = error
                     } receiveValue: { [weak self] dooldaUser in
                         self?.user = dooldaUser
                         self?.validateUser(with: dooldaUser)
                     }.store(in: &self.cancellables)
             }
             .store(in: &self.cancellables)
     }
    
    private func validateUser(with dooldaUser: User) {
        if dooldaUser.isAgreed == false {
            self.agreementPageRequested.send()
        } else if dooldaUser.pairId?.ddidString.isEmpty == false {
            self.diaryPageRequested.send(dooldaUser)
        } else {
            self.pairingPageRequested.send(dooldaUser.id)
        }
    }

    private func applyGlobalFont() {
        guard let globalFont = self.globalFontUseCase.getGlobalFont() else { return }
        self.globalFontUseCase.setGlobalFont(with: globalFont.name)
    }
}
