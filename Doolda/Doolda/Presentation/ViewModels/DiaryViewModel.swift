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
    
    @Published var displayMode: DiaryDisplayMode = .carousel
    
    @Published private var isMyTurn: Bool = false
    @Published private var filteredPageEntities: [PageEntity] = [
        PageEntity(author: User(id: DDID(), pairId: DDID()), timeStamp: Date(), jsonPath: ""),
        PageEntity(author: User(id: DDID(), pairId: DDID()), timeStamp: Date(), jsonPath: "")
    ]
    
    private let coordinator: DiaryViewCoordinatorProtocol
    
    init(coordinator: DiaryViewCoordinatorProtocol) {
        self.coordinator = coordinator
    }

    func displayModeToggleButtonDidTap() {
        self.displayMode.toggle()
    }
    
    func addPageButtonDidTap() {
        print(#function)
    }
    
    func lastPageDidPull() {
        print(#function)
        self.filteredPageEntities.insert(PageEntity(author: User(id: DDID(), pairId: DDID()), timeStamp: Date(), jsonPath: ""), at: 0)
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
