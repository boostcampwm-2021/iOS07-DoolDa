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
    var errorPublisher: Published<Error?>.Publisher { get }
    var displayModePublisher: Published<DiaryDisplayMode>.Publisher { get }
    var isMyTurnPublisher: Published<Bool>.Publisher { get }
    var filteredPageEntitiesPublisher: AnyPublisher<[PageEntity], Never> { get }
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
    var errorPublisher: Published<Error?>.Publisher { self.$error }
    var displayModePublisher: Published<DiaryDisplayMode>.Publisher { self.$displayMode }
    var isMyTurnPublisher: Published<Bool>.Publisher { self.$isMyTurn }
    var isRefreshingPublisher: Published<Bool>.Publisher { self.$isRefreshing }
  
    @Published var displayMode: DiaryDisplayMode = .carousel
    
    lazy var filteredPageEntitiesPublisher: AnyPublisher<[PageEntity], Never> = Publishers
        .CombineLatest3(self.$pageEntities, self.$authorFilter, self.$orderFilter)
        .map { $0.0 }
        .eraseToAnyPublisher()
    
    @Published private var error: Error?
    @Published private var isRefreshing: Bool = false
    @Published private var isMyTurn: Bool = false
    @Published private var filteredPageEntities: [PageEntity] = []
    @Published private var pageEntities: [PageEntity] = []
    @Published private var authorFilter: DiaryAuthorFilter = .user
    @Published private var orderFilter: DiaryOrderFilter = .descending
    
    private var cancellables: Set<AnyCancellable> = []
    
    private let user: User
    private let coordinator: DiaryViewCoordinatorProtocol
    private let checkMyTurnUseCase: CheckMyTurnUseCaseProtocol
    private let getPageUseCase: GetPageUseCaseProtocol
    private let getRawPageUseCase: GetRawPageUseCaseProtocol
    
    init(
        user: User,
        coordinator: DiaryViewCoordinatorProtocol,
        checkMyTurnUseCase: CheckMyTurnUseCaseProtocol,
        getPageUseCase: GetPageUseCaseProtocol,
        getRawPageUseCase: GetRawPageUseCaseProtocol
    ) {
        self.user = user
        self.coordinator = coordinator
        self.checkMyTurnUseCase = checkMyTurnUseCase
        self.getPageUseCase = getPageUseCase
        self.getRawPageUseCase = getRawPageUseCase
        self.fetchPages()
    }
    
    func pageDidDisplay(jsonPath: String) -> AnyPublisher<RawPageEntity, Error> {
        guard let pairId = self.user.pairId else { return Fail(error: DiaryViewModelError.userNotPaired).eraseToAnyPublisher() }
        return self.getRawPageUseCase.getRawPageEntity(for: pairId, jsonPath: jsonPath)
    }

    func displayModeToggleButtonDidTap() {
        self.displayMode.toggle()
    }
    
    func addPageButtonDidTap() {
        self.coordinator.editPageRequested()
    }
    
    func refreshButtonDidTap() {
        self.isRefreshing = true
        self.fetchPages()
    }
    
    func settingsButtonDidTap() {
        self.coordinator.settingsPageRequested()
    }
    
    func filterButtonDidTap() {
        self.coordinator.filteringSheetRequested()
    }
    
    func filterDidApply(author: DiaryAuthorFilter, orderBy: DiaryOrderFilter) {
        self.authorFilter = author
        self.orderFilter = orderBy
    }
    
    private func fetchPages() {
        guard let pairId = self.user.pairId else { return }
        
        self.checkMyTurnUseCase.checkTurn(for: self.user)
            .sink { [weak self] completion in
                guard case .failure(let error) = completion else { return }
                self?.error = error
            } receiveValue: { [weak self] isMyTurn in
                self?.isMyTurn = isMyTurn
            }
            .store(in: &self.cancellables)

        self.getPageUseCase.getPages(for: pairId)
            .sink { [weak self] completion in
                guard case .failure(let error) = completion else { return }
                self?.error = error
            } receiveValue: { [weak self] pages in
                self?.pageEntities = pages
                self?.isRefreshing = false
            }
            .store(in: &self.cancellables)
    }
}
