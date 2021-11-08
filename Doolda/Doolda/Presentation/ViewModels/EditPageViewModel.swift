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
    func canvasDidTap(point: CGPoint)
    func componentDidDrag(difference: CGPoint)
    func componentTransformControlDidPan(difference: CGPoint)
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
