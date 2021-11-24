//
//  PageDetailViewModel.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/24.
//

import Combine
import Foundation

protocol PageDetailViewModelInput {
    func pageDetailViewWillApper()
    func editPageButtonDidTap()
    func getDate() -> Date?
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

    private let pageEntity: PageEntity
    private let getRawPageUseCase: GetRawPageUseCaseProtocol

    init(
        pageEntity: PageEntity,
        getRawPageUseCase: GetRawPageUseCaseProtocol
    ) {
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

    func editPageButtonDidTap() {
        
    }

}
