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
    case failedToSavePage(reason: Error?)
    
    var errorDescription: String? {
        switch self {
        case .rawPageNotFound: return "편집중인 페이지를 찾을 수 없습니다."
        case .failedToSavePage(let reason):
            if let reason = reason {
                return " \(reason.localizedDescription)(으)로 인해 페이지 저장에 실패 했습니다."
            }
            return "페이지 저장에 실패 했습니다."
        }
    }
}

final class EditPageUseCase: EditPageUseCaseProtocol {
    var selectedComponentPublisher: AnyPublisher<ComponentEntity?, Never> { self.$selectedComponent.eraseToAnyPublisher() }
    var rawPagePublisher: AnyPublisher<RawPageEntity?, Never> { self.$rawPage.eraseToAnyPublisher() }
    var errorPublisher: AnyPublisher<Error?, Never> { self.$error.eraseToAnyPublisher() }
    var resultPublisher: AnyPublisher<Bool?, Never> { self.$result.eraseToAnyPublisher() }
    
    private let user: User
    private let imageUseCase: ImageUseCaseProtocol
    private let pageRepository: PageRepositoryProtocol
    private let rawPageRepository: RawPageRepositoryProtocol
    private let pairRepository: PairRepositoryProtocol
    
    private var cancellables: Set<AnyCancellable> = []
    @Published private var selectedComponent: ComponentEntity?    
    @Published private var rawPage: RawPageEntity?
    @Published private var error: Error?
    @Published private var result: Bool?

    init(
        user: User,
        imageUseCase: ImageUseCaseProtocol,
        pageRepository: PageRepositoryProtocol,
        rawPageRepository: RawPageRepositoryProtocol,
        pairRepository: PairRepositoryProtocol
    ) {
        self.user = user
        self.imageUseCase = imageUseCase
        self.rawPage = RawPageEntity()
        self.pageRepository = pageRepository
        self.rawPageRepository = rawPageRepository
        self.pairRepository = pairRepository
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
        self.changeOrderOfComponents(from: indexOfSelectedComponent, to: rawPage.components.count)
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
        self.selectedComponent = self.selectedComponent
    }

    func addComponent(
        _ component: ComponentEntity,
        withSelection: Bool = true
    ) {
        self.rawPage?.append(component: component)
        self.selectedComponent = component
        self.selectedComponent = withSelection ? self.selectedComponent : nil
    }
    
    func changeTextComponent(into content: TextComponentEntity) {
        self.selectedComponent = content
    }
    
    func changeBackgroundType(_ backgroundType: BackgroundType) {
        self.rawPage?.backgroundType = backgroundType
    }

    func savePage(author: User, metaData: PageEntity?) {
        guard let page = self.rawPage else { return self.error = EditPageUseCaseError.rawPageNotFound }
        guard let pairId = author.pairId?.ddidString else { return }
        
        let isNewPage = metaData == nil
        let currentTime = Date()
        let path = DateFormatter.jsonPathFormatter.string(from: currentTime)
        
        let pageEntity = PageEntity(
            author: metaData?.author ?? author,
            createdTime: metaData?.createdTime ?? currentTime,
            updatedTime: currentTime,
            jsonPath: metaData?.jsonPath ?? path
        )

        let imageUploadPublishers = page.components
            .compactMap { $0 as? PhotoComponentEntity }
            .filter { $0.imageUrl.scheme == "file" }
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
            .flatMap { [weak self] _ -> AnyPublisher<PageEntity, Error> in
                guard let self = self else { return Fail(error: EditPageUseCaseError.failedToSavePage(reason: nil)).eraseToAnyPublisher() }
                return isNewPage
                    ? self.pageRepository.savePage(pageEntity)
                    : self.pageRepository.updatePage(pageEntity)
            }
            .flatMap { [weak self] pageEntity -> AnyPublisher<RawPageEntity, Error> in
                guard let self = self else { return Fail(error: EditPageUseCaseError.failedToSavePage(reason: nil)).eraseToAnyPublisher() }
                return self.rawPageRepository.save(rawPage: page, at: pairId, with: pageEntity.jsonPath)
            }
            .flatMap { [weak self] _ -> AnyPublisher<DDID, Error> in
                guard let self = self else { return Fail(error: EditPageUseCaseError.failedToSavePage(reason: nil)).eraseToAnyPublisher() }
                if isNewPage { return self.pairRepository.setRecentlyEditedUser(with: self.user) }
                return Just(self.user.id).setFailureType(to: Error.self).eraseToAnyPublisher()
            }
            .sink { [weak self] completion in
                guard case .failure(let error) = completion else { return }
                self?.error = error
            } receiveValue: { [weak self] _ in
                self?.result = true
            }
            .store(in: &self.cancellables)
    }
}
