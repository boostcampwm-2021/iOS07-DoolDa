//
//  SettingsViewModel.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/22.
//

import Combine
import Foundation

import FirebaseAuth

protocol SettingsViewModelInput {
    func settingsViewDidLoad()
    func fontCellDidTap()
    func fontTypeDidChanged(_ fontName: String)
    func pushNotificationDidToggle(_ isOn: Bool)
    func openSourceCellDidTap()
    func privacyCellDidTap()
    func contributorCellDidTap()
    func unpairButtonDidTap()
    func logoutButtonDidTap()
    func deleteAccountButtonDidTap()
    func deinitRequested()
}

protocol SettingsViewModelOutput {
    var errorPublisher: AnyPublisher<Error?, Never> { get }
    var pushNotificationStatePublisher: AnyPublisher<Bool?, Never> { get }
    var selectedFontPublisher: AnyPublisher<FontType?, Never> { get }
}

typealias SettingsViewModelProtocol = SettingsViewModelInput & SettingsViewModelOutput

final class SettingsViewModel: SettingsViewModelProtocol {
    var errorPublisher: AnyPublisher<Error?, Never> { self.$error.eraseToAnyPublisher() }
    var pushNotificationStatePublisher: AnyPublisher<Bool?, Never> { self.$isPushNotificationOn.eraseToAnyPublisher() }
    var selectedFontPublisher: AnyPublisher<FontType?, Never> { self.$selectedFont.eraseToAnyPublisher() }
    
    var fontPickerSheetRequested = PassthroughSubject<Void, Never>()
    var informationViewRequested = PassthroughSubject<DooldaInfoType, Never>()

    private let sceneId: UUID
    private let user: User
    private let globalFontUseCase: GlobalFontUseCaseProtocol
    private let unpairUserUseCase: UnpairUserUseCaseProtocol
    private let authenticateUseCase: AuthenticateUseCaseProtocol
    private let pushNotificationStateUseCase: PushNotificationStateUseCaseProtocol
    private let firebaseMessageUseCase: FirebaseMessageUseCaseProtocol
    
    private var cancellables: Set<AnyCancellable> = []
    @Published private var error: Error?
    @Published private var isPushNotificationOn: Bool?
    @Published private var selectedFont: FontType?

    init(
        sceneId: UUID,
        user: User,
        globalFontUseCase: GlobalFontUseCaseProtocol,
        unpairUserUseCase: UnpairUserUseCaseProtocol,
        authenticateUseCase: AuthenticateUseCaseProtocol,
        pushNotificationStateUseCase: PushNotificationStateUseCaseProtocol,
        firebaseMessageUseCase: FirebaseMessageUseCaseProtocol
    ) {
        self.sceneId = sceneId
        self.user = user
        self.globalFontUseCase = globalFontUseCase
        self.unpairUserUseCase = unpairUserUseCase
        self.authenticateUseCase = authenticateUseCase
        self.pushNotificationStateUseCase = pushNotificationStateUseCase
        self.firebaseMessageUseCase = firebaseMessageUseCase
    }

    func settingsViewDidLoad() {
        self.isPushNotificationOn = self.pushNotificationStateUseCase.getPushNotificationState()
        self.selectedFont = self.globalFontUseCase.getGlobalFont()
    }

    func fontCellDidTap() {
        self.fontPickerSheetRequested.send()
    }

    func fontTypeDidChanged(_ fontName: String) {
        self.globalFontUseCase.setGlobalFont(with: fontName)
        self.globalFontUseCase.saveGlobalFont(as: fontName)
        self.selectedFont = FontType(fontName: fontName)
    }

    func pushNotificationDidToggle(_ isOn: Bool) {
        self.pushNotificationStateUseCase.setPushNotificationState(as: isOn)
    }

    func openSourceCellDidTap() {
        self.informationViewRequested.send(DooldaInfoType.openSourceLicense)
    }

    func privacyCellDidTap() {
        self.informationViewRequested.send(DooldaInfoType.privacyPolicy)
    }

    func contributorCellDidTap() {
        self.informationViewRequested.send(DooldaInfoType.contributor)
    }
    
    func unpairButtonDidTap() {
        self.unpairUserUseCase.unpair(user: self.user)
            .sink { [weak self] completion in
                guard case .failure(let error) = completion else { return }
                self?.error = error
            } receiveValue: { [weak self] _ in
                if let friendId = self?.user.friendId,
                   friendId != self?.user.id {
                    self?.firebaseMessageUseCase.sendMessage(to: friendId, message: PushMessageEntity.userDisconnected)
                }

                NotificationCenter.default.post(
                    name: AppCoordinator.Notifications.appRestartSignal,
                    object: nil
                )
            }
            .store(in: &self.cancellables)
    }

    func logoutButtonDidTap() {
        do {
            try self.authenticateUseCase.signOut()
            NotificationCenter.default.post(
                name: AppCoordinator.Notifications.appRestartSignal,
                object: nil
            )
        } catch(let error) {
            self.error = error
        }
    }
    
    // FIXME: NOT IMPLEMENTED
    func deleteAccountButtonDidTap() {
        self.authenticateUseCase.delete()
            .sink { [weak self] completion in
            guard case .failure(let error) = completion else { return }
                try? Auth.auth().signOut()
            self?.error = error
        } receiveValue: { _ in
            NotificationCenter.default.post(
                name: AppCoordinator.Notifications.appRestartSignal,
                object: nil
            )
        }
        .store(in: &self.cancellables)
    }
    
    func deinitRequested() {
        NotificationCenter.default.post(
            name: BaseCoordinator.Notifications.coordinatorRemoveFromParent,
            object: nil,
            userInfo: [BaseCoordinator.Keys.sceneId: self.sceneId]
        )
    }
}
