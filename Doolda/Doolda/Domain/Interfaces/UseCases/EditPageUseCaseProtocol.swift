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
    var selectedComponentPublisher: Published<ComponentEntity?>.Publisher { get }
    var rawPagePublisher: Published<RawPageEntity?>.Publisher { get }
    var errorPublisher: Published<Error?>.Publisher { get }
    var resultPublisher: Published<Bool?>.Publisher { get }
    
    func selectComponent(at point: CGPoint)
    func moveComponent(to point: CGPoint)
    func rotateComponent(by angle: CGFloat)
    func scaleComponent(by scale: CGFloat)
    func bringComponentFront()
    func sendComponentBack()
    func removeComponent()
    func addComponent(_ component: ComponentEntity)
    
    func changeTextComponent(into content: TextComponentEntity)
    
    func changeBackgroundType(_ backgroundType: BackgroundType)
    func savePage(author: User, metaData: PageEntity?)
}
