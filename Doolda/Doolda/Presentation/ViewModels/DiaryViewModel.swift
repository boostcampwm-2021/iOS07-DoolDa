//
//  DiaryViewModel.swift
//  Doolda
//
//  Created by Seunghun Yang on 2021/11/16.
//

import Foundation

protocol DiaryViewModelInput {
    func filterButtonDidTap()
    func displayModeToggleButtonDidTap()
    func settingsButtonDidTap()
    func addPageButtonDidTap()
    func lastPageDidPull()
    func filterDidApply(author: DiaryAuthorFilter, orderBy: DiaryOrderFilter)
}

protocol DiaryViewModelOutput {
    var displayModePublisher: Published<DiaryDisplayMode>.Publisher { get }
    var isMyTurnPublisher: Published<Bool>.Publisher { get }
    var filteredPageEntitiesPublisher: Published<[PageEntity]>.Publisher { get }
    var isRefreshingPublisher: Published<Bool>.Publisher { get }
    var displayMode: DiaryDisplayMode { get }
}

typealias DiaryViewModelProtocol = DiaryViewModelInput & DiaryViewModelOutput

enum DiaryDisplayMode {
    case carousel, list
    
    mutating func toggle() {
        switch self {
        case .carousel: self = .list
        case .list: self = .carousel
        }
    }
}

enum DiaryAuthorFilter {
    case user, friend, both
}

enum DiaryOrderFilter {
    case ascending, descending
}

class DiaryViewModel: DiaryViewModelProtocol {
    var displayModePublisher: Published<DiaryDisplayMode>.Publisher { self.$displayMode }
    var isMyTurnPublisher: Published<Bool>.Publisher { self.$isMyTurn }
    var filteredPageEntitiesPublisher: Published<[PageEntity]>.Publisher { self.$filteredPageEntities }
    var isRefreshingPublisher: Published<Bool>.Publisher { self.$isRefreshing }
    
    var number = 2
    
    @Published var displayMode: DiaryDisplayMode = .carousel
    
    @Published private var isMyTurn: Bool = false
    @Published private var filteredPageEntities: [PageEntity] = [
        PageEntity(author: User(id: DDID(), pairId: DDID()), timeStamp: Date(), jsonPath: "1"),
        PageEntity(author: User(id: DDID(), pairId: DDID()), timeStamp: Date(), jsonPath: "0")
    ]
    @Published private var isRefreshing: Bool = false
    
    private let coordinator: DiaryViewCoordinatorProtocol
    
    init(coordinator: DiaryViewCoordinatorProtocol) {
        self.coordinator = coordinator
    }

    func displayModeToggleButtonDidTap() {
        self.displayMode.toggle()
    }
    
    func addPageButtonDidTap() {
        self.coordinator.editPageRequested()
    }
    
    func lastPageDidPull() {
        print(#function)
        self.isRefreshing = true
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }
            self.filteredPageEntities.insert(PageEntity(author: User(id: DDID(), pairId: DDID()), timeStamp: Date(), jsonPath: "\(self.number)"), at: 0)
            self.number += 1
            self.isRefreshing = false
        }
    }
    
    func settingsButtonDidTap() {
        print(#function)
        self.isMyTurn.toggle()
        self.coordinator.settingsPageRequested()
    }
    
    func filterButtonDidTap() {
        print(#function)
        self.coordinator.filteringSheetRequested()
    }
    
    func filterDidApply(author: DiaryAuthorFilter, orderBy: DiaryOrderFilter) {
    }
}
