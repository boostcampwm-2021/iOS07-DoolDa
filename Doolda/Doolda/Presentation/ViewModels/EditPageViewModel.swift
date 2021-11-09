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
    func componentBringForwardControlDidTap()
    func componentSendBackwardControlDidTap()
    func componentRemoveControlDidTap()
    func componentEntityDidAdd(_ component: ComponentEntity)
    func backgroundColorDidChange(_ backgroundColor: BackgroundType)
    func saveEditingPageButtonDidTap()
    func cancelEditingPageButtonDidTap()
}

protocol EditPageViewModelOutput {
    var selectedComponentPublisher: Published<ComponentEntity?>.Publisher { get }
    var isPageSavedPublisher: Published<Bool>.Publisher { get }
    var errorPublisher: Published<Error?>.Publisher { get }
}

typealias EditPageViewModelProtocol = EditPageViewModelInput & EditPageViewModelOutput

final class EditPageViewModel: EditPageViewModelProtocol {
    
    var selectedComponentPublisher: Published<ComponentEntity?>.Publisher { self.$selectedComponent}
    var isPageSavedPublisher: Published<Bool>.Publisher { self.$isPageSaved }
    var errorPublisher: Published<Error?>.Publisher { self.$error }

    private let user: User
    private let coordinator: EditPageViewCoordinatorProtocol
    private let editPageUseCase: EditPageUseCaseProtocol
    private var cancellables: Set<AnyCancellable> = []
    @Published private var selectedComponent: ComponentEntity?
    @Published private var isPageSaved: Bool = false
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
        self.editPageUseCase.selectedComponentPublisher
            .assign(to: &$selectedComponent)
        self.editPageUseCase.errorPublisher
            .assign(to: &$error)
    }
    
    func canvasDidTap(point: CGPoint) {
        self.editPageUseCase.selectComponent(at: point)
    }
    
    func componentDidDrag(difference: CGPoint) {
        self.editPageUseCase.moveComponent(difference: difference)
    }
    
    func componentTransformControlDidPan(difference: CGPoint) {
        self.editPageUseCase.transformComponent(difference: difference)
    }
    
    func componentBringForwardControlDidTap() {
        self.editPageUseCase.bringComponentForward()
    }
    
    func componentSendBackwardControlDidTap() {
        self.editPageUseCase.sendComponentBackward()
    }
    
    func componentRemoveControlDidTap() {
        self.editPageUseCase.removeComponent()
    }
    
    func componentEntityDidAdd(_ component: ComponentEntity) {
        self.editPageUseCase.addComponent(component)
    }
    
    func backgroundColorDidChange(_ backgroundColor: BackgroundType) {
        self.editPageUseCase.changeBackgroundType(backgroundColor)
    }
    
    func saveEditingPageButtonDidTap() {
        self.editPageUseCase.savePage()
    }
    
    func cancelEditingPageButtonDidTap() {
        self.coordinator.editingPageCanceled()
    }
}

