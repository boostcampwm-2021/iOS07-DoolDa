//
//  EditPageViewModel.swift
//  Doolda
//
//  Created by 김민주 on 2021/11/08.
//

import Combine
import CoreGraphics
import Foundation

protocol EditPageViewModelInput {
    func editPageViewDidAppear()

    func canvasDidTap(at point: CGPoint)
    
    func componentDidTap()
    func componentDidDrag(at point: CGPoint)
    func componentDidRotate(by angle: CGFloat)
    func componentDidScale(by scale: CGFloat)
    func componentBringFrontControlDidTap()
    func componentSendBackControlDidTap()
    func componentRemoveControlDidTap()
    
    func textComponentDidChange(to textComponent: TextComponentEntity)
    
    func photoComponentAddButtonDidTap()
    func textComponentAddButtonDidTap()
    func stickerComponentAddButtonDidTap()
    func backgroundTypeButtonDidTap()
    
    func componentEntityDidAdd(_ component: ComponentEntity)
    func backgroundColorDidChange(_ backgroundColor: BackgroundType)
    func saveEditingPageButtonDidTap()
    func cancelEditingPageButtonDidTap()
    func deinitRequested()
}

protocol EditPageViewModelOutput {
    var selectedComponentPublisher: AnyPublisher<ComponentEntity?, Never> { get }
    var componentsPublisher: AnyPublisher<[ComponentEntity], Never> { get }
    var backgroundPublisher: AnyPublisher<BackgroundType, Never> { get }
    var errorPublisher: AnyPublisher<Error?, Never> { get }
}

typealias EditPageViewModelProtocol = EditPageViewModelInput & EditPageViewModelOutput

final class EditPageViewModel: EditPageViewModelProtocol {
    var selectedComponentPublisher: AnyPublisher<ComponentEntity?, Never> { self.$selectedComponent.eraseToAnyPublisher() }
    var componentsPublisher: AnyPublisher<[ComponentEntity], Never> { self.$components.eraseToAnyPublisher() }
    var backgroundPublisher: AnyPublisher<BackgroundType, Never> { self.$background.eraseToAnyPublisher() }
    var errorPublisher: AnyPublisher<Error?, Never> { self.$error.eraseToAnyPublisher() }

    private let sceneId: UUID
    private let user: User
    private let pageEntity: PageEntity?
    private let rawPageEntity: RawPageEntity?
    private let editPageUseCase: EditPageUseCaseProtocol
    private let firebaseMessageUseCase: FirebaseMessageUseCaseProtocol
    
    private var cancellables: Set<AnyCancellable> = []
    
    @Published private var selectedComponent: ComponentEntity? = nil
    @Published private var components: [ComponentEntity] = []
    @Published private var background: BackgroundType = .dooldaBackground
    @Published private var error: Error?
    
    init(
        sceneId: UUID,
        user: User,
        pageEntity: PageEntity? = nil,
        rawPageEntity: RawPageEntity? = nil,
        editPageUseCase: EditPageUseCaseProtocol,
        firebaseMessageUseCase: FirebaseMessageUseCaseProtocol
    ) {
        self.sceneId = sceneId
        self.user = user
        self.pageEntity = pageEntity
        self.rawPageEntity = rawPageEntity
        self.editPageUseCase = editPageUseCase
        self.firebaseMessageUseCase = firebaseMessageUseCase
        bind()
    }
    
    private func bind() {
        self.editPageUseCase.selectedComponentPublisher
            .sink { [weak self] selectedComponent in
                self?.selectedComponent = selectedComponent
            }.store(in : &self.cancellables)
        
        self.editPageUseCase.rawPagePublisher
            .sink { [weak self] rawPageEntity in
                guard let self = self,
                      let rawPageEntity = rawPageEntity else { return }
                self.components = rawPageEntity.components
                self.background = rawPageEntity.backgroundType
            }.store(in : &self.cancellables)
        
        self.editPageUseCase.resultPublisher
            .dropFirst()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if let friendId = self.user.friendId, friendId != self.user.id {
                    self.firebaseMessageUseCase.sendMessage(to: friendId, message: PushMessageEntity.userPostedNewPage)
                }
                NotificationCenter.default.post(name: EditPageViewCoordinator.Notifications.editPageSaved, object: nil)
            }.store(in: &self.cancellables)
        
        self.editPageUseCase.errorPublisher
            .assign(to: &$error)
    }

    func editPageViewDidAppear() {
        guard let rawPageEntity = self.rawPageEntity else { return }
        rawPageEntity.components.forEach { component in
            self.componentEntityDidAdd(component)
        }
        self.backgroundColorDidChange(rawPageEntity.backgroundType)
    }

    func componentDidTap() {
        if let selectedComponent = self.selectedComponent as? TextComponentEntity {
            NotificationCenter.default.post(
                name: EditPageViewCoordinator.Notifications.editTextComponent,
                object: nil,
                userInfo: [EditPageViewCoordinator.Keys.textComponent: selectedComponent]
            )
        }
    }
    
    func canvasDidTap(at point: CGPoint) {
        self.editPageUseCase.selectComponent(at: point)
    }
    
    func componentDidDrag(at point: CGPoint) {
        self.editPageUseCase.moveComponent(to: point)
    }
    
    func componentDidRotate(by angle: CGFloat) {
        self.editPageUseCase.rotateComponent(by: angle)
    }
    
    func componentDidScale(by scale: CGFloat) {
        self.editPageUseCase.scaleComponent(by: scale)
    }
    
    func componentBringFrontControlDidTap() {
        self.editPageUseCase.bringComponentFront()
    }
    
    func componentSendBackControlDidTap() {
        self.editPageUseCase.sendComponentBack()
    }
    
    func componentRemoveControlDidTap() {
        self.editPageUseCase.removeComponent()
    }
    
    func textComponentDidChange(to textComponent: TextComponentEntity) {
        self.editPageUseCase.changeTextComponent(into: textComponent)
    }
    
    func photoComponentAddButtonDidTap() {
        NotificationCenter.default.post(name: EditPageViewCoordinator.Notifications.addPhotoComponent, object: nil)
    }
    
    func textComponentAddButtonDidTap() {
        NotificationCenter.default.post(name: EditPageViewCoordinator.Notifications.editTextComponent, object: nil)
    }
    
    func stickerComponentAddButtonDidTap() {
        NotificationCenter.default.post(name: EditPageViewCoordinator.Notifications.addStickerComponent, object: nil)
    }
    
    func backgroundTypeButtonDidTap() {
        NotificationCenter.default.post(name: EditPageViewCoordinator.Notifications.changeBackgroundType, object: nil)
    }
    
    func componentEntityDidAdd(_ component: ComponentEntity) {
        self.editPageUseCase.addComponent(component)
    }
    
    func backgroundColorDidChange(_ backgroundColor: BackgroundType) {
        self.editPageUseCase.changeBackgroundType(backgroundColor)
    }
    
    func saveEditingPageButtonDidTap() {
        self.editPageUseCase.savePage(author: self.user, metaData: self.pageEntity)
    }
    
    func cancelEditingPageButtonDidTap() {
        NotificationCenter.default.post(name: EditPageViewCoordinator.Notifications.editingPageCanceled, object: nil)
    }
    
    func deinitRequested() {
        NotificationCenter.default.post(
            name: BaseCoordinator.Notifications.coordinatorRemoveFromParent,
            object: nil,
            userInfo: [BaseCoordinator.Keys.sceneId: self.sceneId]
        )
    }
}
