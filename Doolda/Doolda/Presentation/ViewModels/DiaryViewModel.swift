//
//  DiaryViewModel.swift
//  Doolda
//
//  Created by Seunghun Yang on 2021/11/16.
//

import Combine
import Foundation

protocol DiaryViewModelInput {
    func filterButtonDidTap()
    func displayModeToggleButtonDidTap()
    func settingsButtonDidTap()
    func addPageButtonDidTap()
    func refreshButtonDidTap()
    func filterDidApply(author: DiaryAuthorFilter, orderBy: DiaryOrderFilter)
    func pageDidDisplay(jsonPath: String) -> AnyPublisher<RawPageEntity, Error>
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

enum DiaryViewModelError: LocalizedError {
    case userNotPaired
    
    var errorDescription: String? {
        switch self {
        case .userNotPaired:
            return "연결된 짝이 없습니다."
        }
    }
}

class DiaryViewModel: DiaryViewModelProtocol {
    var displayModePublisher: Published<DiaryDisplayMode>.Publisher { self.$displayMode }
    var isMyTurnPublisher: Published<Bool>.Publisher { self.$isMyTurn }
    var filteredPageEntitiesPublisher: Published<[PageEntity]>.Publisher { self.$filteredPageEntities }
    var isRefreshingPublisher: Published<Bool>.Publisher { self.$isRefreshing }
    @Published var displayMode: DiaryDisplayMode = .carousel

    @Published private var isRefreshing: Bool = false
    @Published private var isMyTurn: Bool = false
    @Published private var filteredPageEntities: [PageEntity] = [
        PageEntity(author: User(id: DDID(), pairId: DDID()), timeStamp: Date(), jsonPath: ""),
        PageEntity(author: User(id: DDID(), pairId: DDID()), timeStamp: Date(), jsonPath: ""),
        PageEntity(author: User(id: DDID(), pairId: DDID()), timeStamp: Date(), jsonPath: ""),
        PageEntity(author: User(id: DDID(), pairId: DDID()), timeStamp: Date(), jsonPath: ""),
        PageEntity(author: User(id: DDID(), pairId: DDID()), timeStamp: Date(), jsonPath: ""),
        PageEntity(author: User(id: DDID(), pairId: DDID()), timeStamp: Date(), jsonPath: ""),
        PageEntity(author: User(id: DDID(), pairId: DDID()), timeStamp: Date(), jsonPath: ""),
        PageEntity(author: User(id: DDID(), pairId: DDID()), timeStamp: Date(), jsonPath: ""),
        PageEntity(author: User(id: DDID(), pairId: DDID()), timeStamp: Date(), jsonPath: ""),
        PageEntity(author: User(id: DDID(), pairId: DDID()), timeStamp: Date(), jsonPath: ""),
        PageEntity(author: User(id: DDID(), pairId: DDID()), timeStamp: Date(), jsonPath: ""),
        PageEntity(author: User(id: DDID(), pairId: DDID()), timeStamp: Date(), jsonPath: ""),
        PageEntity(author: User(id: DDID(), pairId: DDID()), timeStamp: Date(), jsonPath: ""),
        PageEntity(author: User(id: DDID(), pairId: DDID()), timeStamp: Date(), jsonPath: ""),
        PageEntity(author: User(id: DDID(), pairId: DDID()), timeStamp: Date(), jsonPath: ""),
        PageEntity(author: User(id: DDID(), pairId: DDID()), timeStamp: Date(), jsonPath: ""),
        PageEntity(author: User(id: DDID(), pairId: DDID()), timeStamp: Date(), jsonPath: ""),
        PageEntity(author: User(id: DDID(), pairId: DDID()), timeStamp: Date(), jsonPath: "")
    ]
    
    private let user: User
    private let coordinator: DiaryViewCoordinatorProtocol
    private let displayPageUseCase: DisplayPageUseCaseProtocol
    
    init(user: User, coordinator: DiaryViewCoordinatorProtocol, displayPageUseCase: DisplayPageUseCaseProtocol) {
        self.user = user
        self.coordinator = coordinator
        self.displayPageUseCase = displayPageUseCase
    }
    
    func pageDidDisplay(jsonPath: String) -> AnyPublisher<RawPageEntity, Error> {
        guard let pairId = self.user.pairId else { return Fail(error: DiaryViewModelError.userNotPaired).eraseToAnyPublisher() }
        return self.displayPageUseCase.getRawPageEntity(for: pairId, jsonPath: jsonPath)
    }

    func displayModeToggleButtonDidTap() {
        self.displayMode.toggle()
    }
    
    func addPageButtonDidTap() {
        self.coordinator.editPageRequested()
    }
    
    func refreshButtonDidTap() {
        print(#function)
        self.isRefreshing = true
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.isRefreshing = false
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
