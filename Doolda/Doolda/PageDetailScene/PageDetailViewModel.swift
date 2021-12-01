//
//  PageDetailViewModel.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/24.
//

import Combine
import Foundation

protocol PageDetailViewModelInput {
    func pageDetailViewWillAppear()
    func isPageEditable() -> Bool
    func getDate() -> Date
    func editPageButtonDidTap()
    func deinitRequested()
}

protocol PageDetailViewModelOuput {
    var rawPageEntityPublisher: AnyPublisher<RawPageEntity?, Never> { get }
    var errorPublisher: AnyPublisher<Error?, Never> { get }
}

typealias PageDetailViewModelProtocol = PageDetailViewModelInput & PageDetailViewModelOuput

class PageDetaillViewModel: PageDetailViewModelProtocol {
    var rawPageEntityPublisher: AnyPublisher<RawPageEntity?, Never> { self.$rawPageEntity.eraseToAnyPublisher() }
    var errorPublisher: AnyPublisher<Error?, Never> { self.$error.eraseToAnyPublisher() }

    @Published private var rawPageEntity: RawPageEntity?
    @Published private var error: Error?
    
    private let sceneId: UUID
    private let user: User
    private let pageEntity: PageEntity
    private let getRawPageUseCase: GetRawPageUseCaseProtocol

    init(
        sceneId: UUID,
        user: User,
        pageEntity: PageEntity,
        getRawPageUseCase: GetRawPageUseCaseProtocol
    ) {
        self.sceneId = sceneId
        self.user = user
        self.pageEntity = pageEntity
        self.getRawPageUseCase = getRawPageUseCase
    }

    private var cancellabels: Set<AnyCancellable> = []

    func pageDetailViewWillAppear() {
        self.getRawPageUseCase.getRawPageEntity(metaData: self.pageEntity)
            .sink { [weak self] completion in
                guard case .failure(let error) = completion else { return }
                self?.error = error
            } receiveValue: { [weak self] rawPageEntity in
                self?.rawPageEntity = rawPageEntity
            }
            .store(in: &self.cancellabels)
    }

    func isPageEditable() -> Bool {
        return self.pageEntity.author.id == self.user.id
    }

    func getDate() -> Date {
        return self.pageEntity.createdTime
    }

    func editPageButtonDidTap() {
        guard let rawPageEntity = self.rawPageEntity else { return }
        NotificationCenter.default.post(
            name: PageDetailViewCoordinator.Notifications.editPageRequested,
            object: self,
            userInfo: [PageDetailViewCoordinator.Keys.rawPageEntity: rawPageEntity]
        )
    }
    
    func deinitRequested() {
        NotificationCenter.default.post(
            name: BaseCoordinator.Notifications.coordinatorRemoveFromParent,
            object: nil,
            userInfo: [BaseCoordinator.Keys.sceneId: self.sceneId]
        )
    }
}
