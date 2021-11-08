//
//  EditPageUseCase.swift
//  Doolda
//
//  Created by Seunghun Yang on 2021/11/08.
//

import Combine
import CoreGraphics

protocol EditPageUseCaseProtocol {
    var selectedComponentPublisher: Published<ComponentEntity?>.Publisher { get }
    var erorrPublisher: Published<Error?>.Publisher { get }
    
    func selectComponent(at point: CGPoint)
    func moveComponent(difference: CGPoint)
    func transformComponent(difference: CGPoint)
    func bringComponentForward()
    func sendComponentBackward()
    func removeComponent()
    func addComponent(_ component: ComponentEntity)
    func changeBackgroundType(_ backgroundType: BackgroundType)
    func savePage()
}
