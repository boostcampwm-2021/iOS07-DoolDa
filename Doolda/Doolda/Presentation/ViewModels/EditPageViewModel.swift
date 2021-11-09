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
    var errorPublisher: Published<Error?>.Publisher { get }
    var selectedComponent: AnyPublisher<ComponentEntity?, Never> { get }
    var isPageSaved: Published<Bool>.Publisher { get }
}

typealias EditPageViewModelProtocol = EditPageViewModelInput & EditPageViewModelOutput

final class EditPageViewModel: EditPageViewModelProtocol {
    
    var selectedComponent: AnyPublisher<ComponentEntity?, Never>
    var errorPublisher: Published<Error?>.Publisher
    var isPageSaved: Published<Bool>.Publisher
    
    private let user: User
    private let coordinator: EditPageViewCoordinatorProtocol
    private let editPageUseCase: EditPageUseCaseProtocol
    private var cancellables: Set<AnyCancellable> = []
    
    init(
        user: User,
        coordinator: EditPageViewCoordinatorProtocol,
        editPageUseCase: EditPageUseCaseProtocol
    ) {
        self.user = user
        self.coordinator = coordinator
        self.editPageUseCase = editPageUseCase
        self.bind()
    }
    
    private func bind() {
        
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
        <#code#>
    }
    
    func backgroundColorDidChange(_ backgroundColor: BackgroundType) {
        self.editPageUseCase.changeBackgroundType(backgroundColor)
    }
    
    func saveEditingPageButtonDidTap() {
        <#code#>
    }
    
    func cancelEditingPageButtonDidTap() {
        <#code#>
    }
}

