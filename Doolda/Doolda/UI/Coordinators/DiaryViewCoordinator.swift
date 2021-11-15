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
    func displayModeChangeButtonDidTap()
    func addPageButtonDidTap()
    func lastPageDidDisplay()
}

protocol DiaryViewModelOutput {
    var displayModePublisher: Published<DisplayMode>.Publisher { get } // zㅔ
    var isMyTurnPublisher: Published<Bool>.Publisher { get }
    var filteredPageEntitiesPublisher: Published<[PageEntity]>.Publisher { get }
    var displayMode: DisplayMode { get }
}

typealias DiaryViewModelProtocol = DiaryViewModelInput & DiaryViewModelOutput

class DummyDiaryViewModel: DiaryViewModelProtocol {
    func displayModeChangeButtonDidTap() {
        self.displayMode.toggle()
    }
    
    func addPageButtonDidTap() {
        print("ADD")
        self.filteredPageEntities.append(PageEntity(author: User(id: DDID(), pairId: DDID()), timeStamp: Date(), jsonPath: ""))
    }
    
    func lastPageDidDisplay() {
        print("LAST")
    }
    
    var displayModePublisher: Published<DisplayMode>.Publisher { self.$displayMode }
    var isMyTurnPublisher: Published<Bool>.Publisher { self.$isMyTurn }
    var filteredPageEntitiesPublisher: Published<[PageEntity]>.Publisher { self.$filteredPageEntities }
    
    @Published var displayMode: DisplayMode = .carousel
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

enum DisplayMode {
    case carousel
    case list
    
    mutating func toggle() {
        switch self {
        case .carousel: self = .list
        case .list: self = .carousel
        }
    }
}
