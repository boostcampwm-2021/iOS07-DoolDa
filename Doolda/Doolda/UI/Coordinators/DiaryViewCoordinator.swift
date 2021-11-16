//
//  DiaryViewCoordinator.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/02.
//

import UIKit

class DiaryViewCoordinator: DiaryViewCoordinatorProtocol {
    
    var presenter: UINavigationController
    private let user: User
    
    init(presenter: UINavigationController, user: User) {
        self.presenter = presenter
        self.user = user
    }
    
    func start() {
        let viewModel = DummyDiaryViewModel()
        
        DispatchQueue.main.async {
            let viewController = DiaryViewController(viewModel: viewModel)
            self.presenter.setViewControllers([viewController], animated: false)
        }
    }
    
    func settingsPageRequested() {
        // FIXME: not implemented
    }
    
    func filteringSheetRequested() {
        // FIXME: not implemented
    }
}

protocol DiaryViewModelInput {
    func filterButtonDidTap()
    func displayModeToggleButtonDidTap()
    func addPageButtonDidTap()
    func lastPageDidDisplay()
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

class DummyDiaryViewModel: DiaryViewModelProtocol {
    func filterButtonDidTap() {
        
    }
    
    func filterDidApply(author: DiaryAuthorFilter, orderBy: DiaryOrderFilter) {
        
    }

    func displayModeToggleButtonDidTap() {
        self.displayMode.toggle()
    }
    
    func addPageButtonDidTap() {
        print("ADD")
        self.filteredPageEntities.append(PageEntity(author: User(id: DDID(), pairId: DDID()), timeStamp: Date(), jsonPath: ""))
    }
    
    func lastPageDidDisplay() {
        print("LAST")
    }
    
    var displayModePublisher: Published<DiaryDisplayMode>.Publisher { self.$displayMode }
    var isMyTurnPublisher: Published<Bool>.Publisher { self.$isMyTurn }
    var filteredPageEntitiesPublisher: Published<[PageEntity]>.Publisher { self.$filteredPageEntities }
    
    @Published var displayMode: DiaryDisplayMode = .carousel
    @Published private var isMyTurn: Bool = false
    @Published private var filteredPageEntities: [PageEntity] = [
        PageEntity(author: User(id: DDID(), pairId: DDID()), timeStamp: Date(), jsonPath: ""),
        PageEntity(author: User(id: DDID(), pairId: DDID()), timeStamp: Date(), jsonPath: ""),
        PageEntity(author: User(id: DDID(), pairId: DDID()), timeStamp: Date(), jsonPath: ""),
        PageEntity(author: User(id: DDID(), pairId: DDID()), timeStamp: Date(), jsonPath: ""),
        PageEntity(author: User(id: DDID(), pairId: DDID()), timeStamp: Date(), jsonPath: ""),
        PageEntity(author: User(id: DDID(), pairId: DDID()), timeStamp: Date(), jsonPath: ""),
        PageEntity(author: User(id: DDID(), pairId: DDID()), timeStamp: Date(), jsonPath: ""),
        PageEntity(author: User(id: DDID(), pairId: DDID()), timeStamp: Date(), jsonPath: "")
    ]
}
