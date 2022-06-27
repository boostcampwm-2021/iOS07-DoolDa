//
//  EditPageUseCaseProtocol.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/29.
//

import Combine
import CoreGraphics
import Foundation

protocol EditPageUseCaseProtocol {
    var selectedComponentPublisher: AnyPublisher<ComponentEntity?, Never> { get }
    var rawPagePublisher: AnyPublisher<RawPageEntity?, Never> { get }
    var errorPublisher: AnyPublisher<Error?, Never> { get }
    var resultPublisher: AnyPublisher<Bool?, Never> { get }
    
    func selectComponent(at point: CGPoint)
    func moveComponent(to point: CGPoint)
    func rotateComponent(by angle: CGFloat)
    func scaleComponent(by scale: CGFloat)
    func bringComponentFront()
    func sendComponentBack()
    func removeComponent()
    func addComponent(_ component: ComponentEntity, withSelection: Bool)
    
    func changeTextComponent(into content: TextComponentEntity)
    
    func changeBackgroundType(_ backgroundType: BackgroundType)
    func savePage(author: User, metaData: PageEntity?)
}
