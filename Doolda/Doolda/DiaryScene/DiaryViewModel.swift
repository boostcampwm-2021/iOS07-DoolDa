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
    func changeDisplayedPage(to index: Int)
    func filterDidApply(author: DiaryAuthorFilter, orderBy: DiaryOrderFilter)
    func filterOptionDidChange(author: DiaryAuthorFilter, orderBy: DiaryOrderFilter)
    func filterBottomSheetDidDismiss()
    func pageDidDisplay(metaData: PageEntity) -> AnyPublisher<RawPageEntity, Error>
    func pageDidTap(index: Int)
    func getDate(of index: Int) -> Date?
    func deinitRequested()
}

protocol DiaryViewModelOutput {
    var errorPublisher: AnyPublisher<Error?, Never> { get }
    var displayModePublisher: AnyPublisher<DiaryDisplayMode, Never> { get }
    var isMyTurnPublisher: AnyPublisher<Bool, Never> { get }
    var filteredPageEntitiesPublisher: AnyPublisher<[PageEntity], Never> { get }
    var isRefreshingPublisher: AnyPublisher<Bool, Never> { get }
    var displayMode: DiaryDisplayMode { get }
    var filteredEntityCount: Int { get }
    var lastDisplayedPage: Int { get }
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

final class DiaryViewModel: DiaryViewModelProtocol {
    var errorPublisher: AnyPublisher<Error?, Never> { self.$error.eraseToAnyPublisher() }
    var displayModePublisher: AnyPublisher<DiaryDisplayMode, Never> { self.$displayMode.eraseToAnyPublisher() }
    var isMyTurnPublisher: AnyPublisher<Bool, Never> { self.$isMyTurn.eraseToAnyPublisher() }
    var isRefreshingPublisher: AnyPublisher<Bool, Never> { self.$isRefreshing.eraseToAnyPublisher() }
    var filteredPageEntitiesPublisher: AnyPublisher<[PageEntity], Never> { self.$filteredPageEntities.eraseToAnyPublisher() }
    var filteredEntityCount: Int { self.filteredPageEntities.count }
    
    var addPageRequested = PassthroughSubject<Void, Never>()
    var settingsPageRequested = PassthroughSubject<Void, Never>()
    var pageDetailRequested = PassthroughSubject<PageEntity, Never>()
    var filteringSheetRequested = PassthroughSubject<(DiaryAuthorFilter, DiaryOrderFilter), Never>()
    var lastDisplayedPage: Int = 0
    
    @Published var displayMode: DiaryDisplayMode = .carousel
    @Published private var error: Error?
    @Published private var isRefreshing: Bool = false
    @Published private var isMyTurn: Bool = false
    @Published private var filteredPageEntities: [PageEntity] = []
    @Published private var pageEntities: [PageEntity] = []
    @Published private var authorFilter: DiaryAuthorFilter = .both
    @Published private var orderFilter: DiaryOrderFilter = .descending
    
    private var cancellables: Set<AnyCancellable> = []
    private let sceneId: UUID
    private let user: User
    private let checkMyTurnUseCase: CheckMyTurnUseCaseProtocol
    private let getPageUseCase: GetPageUseCaseProtocol
    private let getRawPageUseCase: GetRawPageUseCaseProtocol
    private let firebaseMessageUseCase: FirebaseMessageUseCaseProtocol
    
    init(
        sceneId: UUID,
        user: User,
        checkMyTurnUseCase: CheckMyTurnUseCaseProtocol,
        getPageUseCase: GetPageUseCaseProtocol,
        getRawPageUseCase: GetRawPageUseCaseProtocol,
        firebaseMessageUseCase: FirebaseMessageUseCaseProtocol
    ) {
        self.sceneId = sceneId
        self.user = user
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
        
        NotificationCenter.default.publisher(for: PushMessageEntity.Notifications.didReceiveUserPostedNewPageEvent)
            .sink { [weak self] _ in
                self?.fetchPages()
            }
            .store(in: &self.cancellables)
        
        NotificationCenter.default.publisher(for: PushMessageEntity.Notifications.didReceiveUserRequestedNewPageEvent)
            .sink { [weak self] _ in
                self?.addPageRequested.send()
            }
            .store(in: &self.cancellables)
    }
    
    func diaryViewWillAppear() {
        self.fetchPages()
    }
    
    func pageDidDisplay(metaData: PageEntity) -> AnyPublisher<RawPageEntity, Error> {
        return self.getRawPageUseCase.getRawPageEntity(metaData: metaData)
    }
    
    func pageDidTap(index: Int) {
        let selectedPageEntity = self.filteredPageEntities[index]
        self.lastDisplayedPage = index + 1
        self.pageDetailRequested.send(selectedPageEntity)
    }

    func displayModeToggleButtonDidTap() {
        self.displayMode.toggle()
    }
    
    func addPageButtonDidTap() {
        self.addPageRequested.send()
    }
    
    func refreshButtonDidTap() {
        self.fetchPages(isNotificationNeeded: true)
    }
    
    func settingsButtonDidTap() {
        self.settingsPageRequested.send()
    }
    
    func filterButtonDidTap() {
        self.filteringSheetRequested.send((self.authorFilter, self.orderFilter))
    }
    
    func changeDisplayedPage(to index: Int) {
        self.lastDisplayedPage = index
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
    
    private func fetchPages(isNotificationNeeded: Bool = false) {
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
                if isNotificationNeeded, self?.isMyTurn == isMyTurn {
                    guard let friendId = self?.user.friendId,
                          friendId != self?.user.id else { return }
                    self?.firebaseMessageUseCase.sendMessage(to: friendId, message: PushMessageEntity.userRequestedNewPage)
                }
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
    
    func deinitRequested() {
        NotificationCenter.default.post(
            name: BaseCoordinator.Notifications.coordinatorRemoveFromParent,
            object: nil,
            userInfo: [BaseCoordinator.Keys.sceneId: self.sceneId]
        )
    }
}
