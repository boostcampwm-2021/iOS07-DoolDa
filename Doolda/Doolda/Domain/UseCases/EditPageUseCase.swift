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
    
    func selectComponent(at point: CGPoint)
    func moveComponent(difference: CGPoint)
    func transformComponent(difference: CGPoint)
    func bringComponentForward() -> [ComponentEntity]
    func sendComponentBackward() -> [ComponentEntity]
    func removeComponent()
    func addComponent(_ component: ComponentEntity)
    func changeBackgroundType(_ backgroundType: BackgroundType)
    func savePage() -> AnyPublisher<Void, Error>
}

class EditPageUseCase: EditPageUseCaseProtocol {
    var selectedComponentPublisher: Published<ComponentEntity?>.Publisher { self.$selectedComponent }
    var errorPublisher: Published<Error?>.Publisher
    
    private var rawPage: RawPageEntity
    private let pageRepository: PageRepositoryProtocol
    private let rawPageRepository: RawPageRepositoryProtocol
    
    @Published private var selectedComponent: ComponentEntity?
    
    init(pageRepository: PageRepositoryProtocol, rawPageRepository: RawPageRepositoryProtocol) {
        self.rawPage = RawPageEntity()
        self.pageRepository = pageRepository
        self.rawPageRepository = rawPageRepository
    }
    
    func selectComponent(at point: CGPoint) {
        for component in rawPage.components {
            if component.hitTest(at: point) {
                self.selectedComponent = component
                break
            }
        }
    }
    
    func moveComponent(difference: CGPoint) {
        <#code#>
    }
    
    func transformComponent(difference: CGPoint) {
        <#code#>
    }
    
    func bringComponentForward() {
        <#code#>
    }
    
    func sendComponentBackward() {
        <#code#>
    }
    
    func removeComponent() {
        <#code#>
    }
    
    func addComponent(_ component: ComponentEntity) {
        <#code#>
    }
    
    func changeBackgroundType(_ backgroundType: BackgroundType) {
        <#code#>
    }
    
    func savePage() {
        <#code#>
    }
    
    
}
