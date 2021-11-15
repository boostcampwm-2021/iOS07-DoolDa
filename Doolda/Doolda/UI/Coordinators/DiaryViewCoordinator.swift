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
  func addPageButtonDidTap()
  func lastPageDidDisplay()
}

protocol DiaryViewModelOutput {
  var isMyTurn: Published<Bool>.Publisher { get }
  var filteredPageEntities: Published<[PageEntity]>.Publisher { get }
}

typealias DiaryViewModelProtocol = DiaryViewModelInput & DiaryViewModelOutput

class DummyDiaryViewModel: DiaryViewModelProtocol {
    func addPageButtonDidTap() {
        print("ADD")
        self.filteredEntities.append(PageEntity(author: User(id: DDID(), pairId: DDID()), timeStamp: Date(), jsonPath: ""))
    }
    
    func lastPageDidDisplay() {
        print("LAST")
    }
    
    var isMyTurn: Published<Bool>.Publisher { self.$turn }
    var filteredPageEntities: Published<[PageEntity]>.Publisher { self.$filteredEntities }
    
    @Published private var turn: Bool = false
    @Published private var filteredEntities: [PageEntity] = [
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
