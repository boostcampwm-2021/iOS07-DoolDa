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
    func canvasDidTap(at point: CGPoint)
    func componentDidDrag(at point: CGPoint)
    func componentDidRotate(by angle: CGFloat)
    func componentDidScale(by scale: CGFloat)
    func componentBringFrontControlDidTap()
    func componentSendBackControlDidTap()
    func componentRemoveControlDidTap()
    
    func photoComponentAddButtonDidTap()
    func textComponentAddButtonDidTap()
    func stickerComponentAddButtonDidTap()
    func backgroundTypeButtonDidTap()
    
    func componentEntityDidAdd(_ component: ComponentEntity)
    func backgroundColorDidChange(_ backgroundColor: BackgroundType)
    func saveEditingPageButtonDidTap()
    func cancelEditingPageButtonDidTap()
}

protocol EditPageViewModelOutput {
    var selectedComponentPublisher: Published<ComponentEntity?>.Publisher { get }
    var componentsPublisher: Published<[ComponentEntity]>.Publisher { get }
    var backgroundPublisher: Published<BackgroundType>.Publisher { get }
    var errorPublisher: Published<Error?>.Publisher { get }
}

typealias EditPageViewModelProtocol = EditPageViewModelInput & EditPageViewModelOutput

final class EditPageViewModel: EditPageViewModelProtocol {
    var selectedComponentPublisher: Published<ComponentEntity?>.Publisher { self.editPageUseCase.selectedComponentPublisher }
    var componentsPublisher: Published<[ComponentEntity]>.Publisher { self.$components }
    var backgroundPublisher: Published<BackgroundType>.Publisher { self.$background }
    var errorPublisher: Published<Error?>.Publisher { self.$error }

    private let user: User
    private let coordinator: EditPageViewCoordinatorProtocol
    private let editPageUseCase: EditPageUseCaseProtocol
    private var cancellables: Set<AnyCancellable> = []
    
    @Published private var components: [ComponentEntity] = []
    @Published private var background: BackgroundType = .dooldaBackground
    @Published private var error: Error?
    
    init(
        user: User,
        coordinator: EditPageViewCoordinatorProtocol,
        editPageUseCase: EditPageUseCaseProtocol
    ) {
        self.user = user
        self.coordinator = coordinator
        self.editPageUseCase = editPageUseCase
        bind()
    }
    
    private func bind() {
        self.editPageUseCase.rawPagePublisher
            .sink { [weak self] rawPageEntity in
                guard let self = self,
                      let rawPageEntity = rawPageEntity else { return }
                self.components = rawPageEntity.components
                self.background = rawPageEntity.backgroundType
            }.store(in : &cancellables)
        
        self.editPageUseCase.resultPublisher
            .sink { _ in
                self.coordinator.editingPageSaved()
            }.store(in: &cancellables)
        
        self.editPageUseCase.errorPublisher
            .assign(to: &$error)
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
    
    func photoComponentAddButtonDidTap() {
        self.coordinator.addPhotoComponent()
    }
    
    func textComponentAddButtonDidTap() {
        self.coordinator.addTextComponent()
    }
    
    func stickerComponentAddButtonDidTap() {
        self.coordinator.addStickerComponent()
        // FIXME : goto coordinator delete dummy component
        let dummyComponent = PhotoComponentEntity(
            frame: CGRect(
                origin: CGPoint(x: 850, y: 1500),
                size: CGSize(width: 700, height: 700)
            ),
            scale: 1,
            angle: 0,
            aspectRatio: 1,
            imageUrl: URL(string: "https://item.kakaocdn.net/do/d0abc6fe74e616536cf07626699bbc707154249a3890514a43687a85e6b6cc82")!
        )
        self.editPageUseCase.addComponent(dummyComponent)
    }
    
    func backgroundTypeButtonDidTap() {
        self.coordinator.changeBackgroundType()
    }
    
    func componentEntityDidAdd(_ component: ComponentEntity) {
        self.editPageUseCase.addComponent(component)
    }
    
    func backgroundColorDidChange(_ backgroundColor: BackgroundType) {
        self.editPageUseCase.changeBackgroundType(backgroundColor)
    }
    
    func saveEditingPageButtonDidTap() {
        self.editPageUseCase.savePage(author: self.user)
    }
    
    func cancelEditingPageButtonDidTap() {
        self.coordinator.editingPageCanceled()
    }
}
