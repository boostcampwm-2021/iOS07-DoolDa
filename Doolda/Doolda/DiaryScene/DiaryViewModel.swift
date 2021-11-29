//
//  DiaryViewModel.swift
//  Doolda
//
//  Created by Seunghun Yang on 2021/11/16.
//

import Combine
import Foundation

protocol DiaryViewModelInput {
    func diaryViewWillAppear()
    func filterButtonDidTap()
    func displayModeToggleButtonDidTap()
    func settingsButtonDidTap()
    func addPageButtonDidTap()
    func refreshButtonDidTap()
    func filterDidApply(author: DiaryAuthorFilter, orderBy: DiaryOrderFilter)
    func filterOptionDidChange(author: DiaryAuthorFilter, orderBy: DiaryOrderFilter)
    func filterBottomSheetDidDismiss()
    func pageDidDisplay(metaData: PageEntity) -> AnyPublisher<RawPageEntity, Error>
    func pageDidTap(index: Int)
    func getDate(of index: Int) -> Date?
    func userPostedNewPageNotificationDidReceived()
    func userRequestedNewPageNotificationDidReceived()
}

protocol DiaryViewModelOutput {
    var errorPublisher: Published<Error?>.Publisher { get }
    var displayModePublisher: Published<DiaryDisplayMode>.Publisher { get }
    var isMyTurnPublisher: Published<Bool>.Publisher { get }
    var filteredPageEntitiesPublisher: Published<[PageEntity]>.Publisher { get }
    var isRefreshingPublisher: Published<Bool>.Publisher { get }
    var displayMode: DiaryDisplayMode { get }
    var filteredEntityCount: Int { get }
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

enum DiaryAuthorFilter: String, CaseIterable {
    case both = "전체 보기"
    case user = "내 것만 보기"
    case friend = "친구 것만 보기"
    
    static var titles: [String] { DiaryAuthorFilter.allCases.map { $0.rawValue }}

    static subscript(index: Int) -> DiaryAuthorFilter? {
        return DiaryAuthorFilter(rawValue: DiaryAuthorFilter.titles[index])
    }
    
    static func indexOf(authorFilter: DiaryAuthorFilter) -> Int {
        return DiaryAuthorFilter.allCases.firstIndex(of: authorFilter) ?? 0
    }
}

enum DiaryOrderFilter: String, CaseIterable {
    case descending = "최신순"
    case ascending = "오래된순"
    
    static var titles: [String] { DiaryOrderFilter.allCases.map { $0.rawValue }}
    
    static subscript(index: Int) -> DiaryOrderFilter? {
        return DiaryOrderFilter(rawValue: DiaryOrderFilter.titles[index])
    }
    
    static func indexOf(orderFilter: DiaryOrderFilter) -> Int {
        return DiaryOrderFilter.allCases.firstIndex(of: orderFilter) ?? 0
    }
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
    var filteredPageEntitiesPublisher: Published<[PageEntity]>.Publisher { self.$filteredPageEntities }
    var filteredEntityCount: Int { self.filteredPageEntities.count }
  
    @Published var displayMode: DiaryDisplayMode = .carousel
    @Published private var error: Error?
    @Published private var isRefreshing: Bool = false
    @Published private var isMyTurn: Bool = false
    @Published private var filteredPageEntities: [PageEntity] = []
    @Published private var pageEntities: [PageEntity] = []
    @Published private var authorFilter: DiaryAuthorFilter = .both
    @Published private var orderFilter: DiaryOrderFilter = .descending
    
    private var cancellables: Set<AnyCancellable> = []
    
    private let user: User
    private let coordinator: DiaryViewCoordinatorProtocol
    private let checkMyTurnUseCase: CheckMyTurnUseCaseProtocol
    private let getPageUseCase: GetPageUseCaseProtocol
    private let getRawPageUseCase: GetRawPageUseCaseProtocol
    private let firebaseMessageUseCase: FirebaseMessageUseCaseProtocol
    
    init(
        user: User,
        coordinator: DiaryViewCoordinatorProtocol,
        checkMyTurnUseCase: CheckMyTurnUseCaseProtocol,
        getPageUseCase: GetPageUseCaseProtocol,
        getRawPageUseCase: GetRawPageUseCaseProtocol,
        firebaseMessageUseCase: FirebaseMessageUseCaseProtocol
    ) {
        self.user = user
        self.coordinator = coordinator
        self.checkMyTurnUseCase = checkMyTurnUseCase
        self.getPageUseCase = getPageUseCase
        self.getRawPageUseCase = getRawPageUseCase
        self.firebaseMessageUseCase = firebaseMessageUseCase
        self.bind()
    }
    
    private func bind() {
        self.$pageEntities
            .sink { [weak self] entities in
                guard let self = self else { return }
                self.filterPageEntities(entities: entities, authorFilter: self.authorFilter, orderFilter: self.orderFilter)
            }
            .store(in: &self.cancellables)
    }
    
    func diaryViewWillAppear() {
        self.fetchPages()
    }
    
    func pageDidDisplay(metaData: PageEntity) -> AnyPublisher<RawPageEntity, Error> {
        return self.getRawPageUseCase.getRawPageEntity(metaData: metaData)
    }
    
    func pageDidTap(index: Int)  {
        let selectedPageEntity = self.pageEntities[index]
        self.coordinator.pageDetailRequested(pageEntity: selectedPageEntity)
    }

    func displayModeToggleButtonDidTap() {
        self.displayMode.toggle()
    }
    
    func addPageButtonDidTap() {
        self.coordinator.editPageRequested()
    }
    
    func refreshButtonDidTap() {
        self.fetchPages()
        
        guard let friendId = user.friendId,
              friendId != user.id else { return }
        self.firebaseMessageUseCase.sendMessage(to: friendId, message: PushMessageEntity.userRequestedNewPage)
    }
    
    func settingsButtonDidTap() {
        self.coordinator.settingsPageRequested()
    }
    
    func filterButtonDidTap() {
        self.coordinator.filteringSheetRequested(authorFilter: self.authorFilter, orderFilter: self.orderFilter)
    }
    
    func filterDidApply(author: DiaryAuthorFilter, orderBy: DiaryOrderFilter) {
        self.authorFilter = author
        self.orderFilter = orderBy
    }
    
    func filterBottomSheetDidDismiss() {
        self.filterPageEntities(entities: self.pageEntities, authorFilter: self.authorFilter, orderFilter: self.orderFilter)
    }
    
    func filterOptionDidChange(author: DiaryAuthorFilter, orderBy: DiaryOrderFilter) {
        self.filterPageEntities(entities: self.pageEntities, authorFilter: author, orderFilter: orderBy)
    }
    
    func getDate(of index: Int) -> Date? {
        return filteredPageEntities[exist: index]?.createdTime
    }
    
    func userPostedNewPageNotificationDidReceived() {
        self.fetchPages()
    }
    
    func userRequestedNewPageNotificationDidReceived() {
        self.fetchPages()
    }
    
    private func fetchPages() {
        guard let pairId = self.user.pairId else { return }
        self.isRefreshing = true
        
        Publishers.Zip(
            self.checkMyTurnUseCase.checkTurn(for: self.user),
            self.getPageUseCase.getPages(for: pairId)
        )
            .delay(for: .seconds(1), scheduler: DispatchQueue.global())
            .sink { [weak self] completion in
                guard case .failure(let error) = completion else { return }
                self?.error = error
                self?.isRefreshing = false
            } receiveValue: { [weak self] isMyTurn, pages in
                self?.isMyTurn = isMyTurn
                self?.pageEntities = pages
                self?.isRefreshing = false
            }
            .store(in: &self.cancellables)
    }
    
    private func filterPageEntities(entities: [PageEntity], authorFilter: DiaryAuthorFilter, orderFilter: DiaryOrderFilter) {
        let filtered = entities.filter { authorFilter == .both ? true : (authorFilter == .user ? ($0.author.id == self.user.id) : ($0.author.id != self.user.id)) }
        let ordered = filtered.sorted { orderFilter == .descending ? ($0.createdTime >= $1.createdTime) : ($0.createdTime <= $1.createdTime) }
        self.filteredPageEntities = ordered
    }
}
