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
    func moveComponent(to point: CGPoint)
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

    private var cancellables: Set<AnyCancellable> = []
    private var rawPage: RawPageEntity
    @Published private var selectedComponent: ComponentEntity?

    private let pageRepository: PageRepositoryProtocol
    private let rawPageRepository: RawPageRepositoryProtocol


    init(pageRepository: PageRepositoryProtocol, rawPageRepository: RawPageRepositoryProtocol) {
        self.rawPage = RawPageEntity()
        self.pageRepository = pageRepository
        self.rawPageRepository = rawPageRepository
        bind()
    }

    private func bind() {
        self.selectedComponent?.objectWillChange
            .sink { [weak self] in
                guard let self = self else { return }
                self.selectedComponent = self.selectedComponent
            }
            .store(in: &cancellables)
    }

    func selectComponent(at point: CGPoint) {
        guard let rawPage = self.rawPage else { return }
        for component in rawPage.components {
            if component.hitTest(at: point) {
                return self.selectedComponent = component
            }
        }
        return self.selectedComponent = nil
    }
    
    func moveComponent(to point: CGPoint) {
        self.selectedComponent?.origin = point
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
        self.rawPage.append(component)
        self.selectedComponent = component
    }

    func changeBackgroundType(_ backgroundType: BackgroundType) {
        <#code#>
    }
    
    func savePage() {
        <#code#>
    }
    
    
}
