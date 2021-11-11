//
//  EditPageUseCase.swift
//  Doolda
//
//  Created by Seunghun Yang on 2021/11/08.
//

import Combine
import CoreGraphics
import Foundation

enum EditPageUseCaseError: LocalizedError {
    case rawPageNotFound
    
    var errorDescription: String? {
        switch self {
        case .rawPageNotFound: return "편집중인 페이지를 찾을 수 없습니다."
        }
    }
}

protocol EditPageUseCaseProtocol {
    var selectedComponentPublisher: Published<ComponentEntity?>.Publisher { get }
    var rawPagePublisher: Published<RawPageEntity?>.Publisher { get }
    var errorPublisher: Published<Error?>.Publisher { get }
    var resultPublisher: Published<Void?>.Publisher { get }
    
    func selectComponent(at point: CGPoint)
    func moveComponent(to point: CGPoint)
    func rotateComponent(by angle: CGFloat)
    func scaleComponent(by scale: CGFloat)
    func bringComponentFront()
    func sendComponentBack()
    func removeComponent()
    func addComponent(_ component: ComponentEntity)
    func changeBackgroundType(_ backgroundType: BackgroundType)
    func savePage(author: User)
}

class EditPageUseCase: EditPageUseCaseProtocol {
    var selectedComponentPublisher: Published<ComponentEntity?>.Publisher { self.$selectedComponent }
    var rawPagePublisher: Published<RawPageEntity?>.Publisher { self.$rawPage }
    var errorPublisher: Published<Error?>.Publisher { self.$error }
    var resultPublisher: Published<Void?>.Publisher { self.$result }
    
    private let imageUseCase: ImageUseCaseProtocol
    private let pageRepository: PageRepositoryProtocol
    private let rawPageRepository: RawPageRepositoryProtocol
    
    private var cancellables: Set<AnyCancellable> = []
    @Published private var selectedComponent: ComponentEntity?
    @Published private var rawPage: RawPageEntity?
    @Published private var error: Error?
    @Published private var result: Void?

    init(imageUseCase: ImageUseCaseProtocol, pageRepository: PageRepositoryProtocol, rawPageRepository: RawPageRepositoryProtocol) {
        self.imageUseCase = imageUseCase
        self.rawPage = RawPageEntity()
        self.pageRepository = pageRepository
        self.rawPageRepository = rawPageRepository
    }
    
    func selectComponent(at point: CGPoint) {
        guard let rawPage = self.rawPage else { return }
        for component in rawPage.components.reversed() {
            if component.hitTest(at: point) {
                return self.selectedComponent = component
            }
        }
        return self.selectedComponent = nil
    }

    func moveComponent(to point: CGPoint) {
        self.selectedComponent?.origin = point
        self.selectedComponent = self.selectedComponent
    }
    
    func scaleComponent(by scale: CGFloat) {
        self.selectedComponent?.scale = scale
        self.selectedComponent = self.selectedComponent
    }

    func rotateComponent(by angle: CGFloat) {
        self.selectedComponent?.angle = angle
        self.selectedComponent = self.selectedComponent
    }

    func bringComponentFront() {
        guard let rawPage = self.rawPage,
              let selectedComponent = self.selectedComponent,
              let indexOfSelectedComponent = rawPage.indexOf(component: selectedComponent) else { return }
        self.changeOrderOfComponents(from: indexOfSelectedComponent, to: rawPage.numberOfComponents)
    }

    func sendComponentBack() {
        guard let rawPage = self.rawPage,
              let selectedComponent = self.selectedComponent,
              let indexOfSelectedComponent = rawPage.indexOf(component: selectedComponent) else { return }
        self.changeOrderOfComponents(from: indexOfSelectedComponent, to: 0)
    }
    
    private func changeOrderOfComponents(from index: Int, to another: Int) {
        guard var components = self.rawPage?.components else { return }
        let target = components.remove(at: index)
        components.insert(target, at: min(max(another, 0), components.count))
        self.rawPage?.components = components
    }

    func removeComponent() {
        guard let selectedComponent = self.selectedComponent,
              let indexOfSelectedComponent = self.rawPage?.indexOf(component: selectedComponent) else { return }
        self.rawPage?.remove(at: indexOfSelectedComponent)
        self.selectedComponent = nil
    }

    func addComponent(_ component: ComponentEntity) {
        self.rawPage?.append(component: component)
        self.selectedComponent = component
    }

    func changeBackgroundType(_ backgroundType: BackgroundType) {
        self.rawPage?.backgroundType = backgroundType
    }

    func savePage(author: User) {
        guard let page = self.rawPage else { return self.error = EditPageUseCaseError.rawPageNotFound }
        let currentTime = Date()
        let path = DateFormatter.jsonPathFormatter.string(from: currentTime)
        let metaData = PageEntity(author: author, timeStamp: currentTime, jsonPath: path)
        
        let imageUploadPublishers = page.components
            .compactMap { $0 as? PhotoComponentEntity }
            .map { [weak self] photoComponent -> AnyPublisher<URL, Error> in
                guard let self = self else { return Fail(error: EditPageUseCaseError.rawPageNotFound).eraseToAnyPublisher() }
                return self.imageUseCase.saveRemote(for: author, localUrl: photoComponent.imageUrl)
                    .map { remoteUrl in
                        photoComponent.imageUrl = remoteUrl
                        return remoteUrl
                    }
                    .eraseToAnyPublisher()
            }
        
        Publishers.MergeMany(imageUploadPublishers)
            .collect()
            .eraseToAnyPublisher()
            .sink { [weak self] completion in
                guard case .failure(let error) = completion else { return }
                self?.error = error
            } receiveValue: { [weak self] _ in
                guard let self = self else { return }
                Publishers.Zip(self.pageRepository.savePage(metaData), self.rawPageRepository.saveRawPage(page))
                    .sink { [weak self] completion in
                        guard case .failure(let error) = completion else { return }
                        self?.error = error
                    } receiveValue: { [weak self] _ in
                        self?.result = ()
                    }
                    .store(in: &self.cancellables)
            }
            .store(in: &self.cancellables)
    }
}
