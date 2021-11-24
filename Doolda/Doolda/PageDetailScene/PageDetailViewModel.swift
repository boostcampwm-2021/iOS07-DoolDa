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
}

protocol PageDetailViewModelOuput {
    var rawPageEntityPublisher: Published<RawPageEntity?>.Publisher { get }
    var errorPublisher: Published<Error?>.Publisher { get }
}

typealias PageDetailViewModelProtocol = PageDetailViewModelInput & PageDetailViewModelOuput

class PageDetaillViewModel: PageDetailViewModelProtocol {
    var rawPageEntityPublisher: Published<RawPageEntity?>.Publisher { self.$rawPageEntity }
    var errorPublisher: Published<Error?>.Publisher { self.$error }

    @Published private var rawPageEntity: RawPageEntity?
    @Published private var error: Error?

    private let user: User
    private let pageEntity: PageEntity
    private let coordinator: PageDetailViewCoordinatorProtocol
    private let getRawPageUseCase: GetRawPageUseCaseProtocol

    init(
        user: User,
        pageEntity: PageEntity,
        coordinator: PageDetailViewCoordinatorProtocol,
        getRawPageUseCase: GetRawPageUseCaseProtocol
    ) {
        self.user = user
        self.pageEntity = pageEntity
        self.coordinator = coordinator
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
        self.coordinator.editPageRequested(with: rawPageEntity)
    }

}
