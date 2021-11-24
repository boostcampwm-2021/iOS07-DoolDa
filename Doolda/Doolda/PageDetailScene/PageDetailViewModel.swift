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

    init(pageEntity: PageEntity) {
        self.pageEntity = pageEntity
    }

    private var cancellabels: Set<AnyCancellable> = []

    func editPageButtonDidTap() {

    }

    func backButtonDidTap() {

    }
}
