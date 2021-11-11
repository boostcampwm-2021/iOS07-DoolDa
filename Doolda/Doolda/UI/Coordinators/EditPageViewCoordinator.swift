//
//  EditPageViewCoordinator.swift
//  Doolda
//
//  Created by 김민주 on 2021/11/09.
//

import Combine
import UIKit

class EditPageViewCoordinator: EditPageViewCoordinatorProtocol {
    var presenter: UINavigationController
    private let user: User
    
    init(presenter: UINavigationController, user: User) {
        self.presenter = presenter
        self.user = user
    }
    
    func start() {
        DispatchQueue.main.async {
            // FIXME : inject useCase and viewModel
            let dummyImageUseCase = DummyImageUseCase(isSuccessMode: true)
            let dummyPageRepository = DummyPageRepository(isSuccessMode: true)
            let dummyRawPageRepository = DummyRawPageRepository(isSuccessMode: true)
            
            let editPageUseCase = EditPageUseCase(imageUseCase: dummyImageUseCase, pageRepository: dummyPageRepository, rawPageRepository: dummyRawPageRepository)
            let editPageViewModel = EditPageViewModel(user: self.user, coordinator: self, editPageUseCase: editPageUseCase)
            let viewController = EditPageViewController(viewModel: editPageViewModel)
            self.presenter.setViewControllers([viewController], animated: false)
        }
    }
    
    func editingPageSaved() {}
    func editingPageCanceled() {}
}

enum TestError: Error {
    case notImplemented
    case failed
}

class DummyImageUseCase: ImageUseCaseProtocol {
    var isSuccessMode: Bool = true
    
    init(isSuccessMode: Bool) {
        self.isSuccessMode = isSuccessMode
    }
    
    func saveLocal(image: CIImage) -> AnyPublisher<URL, Never> {
        return Just(URL(string: "https://naver.com")!).eraseToAnyPublisher()
    }
    
    func saveRemote(for user: User, localUrl: URL) -> AnyPublisher<URL, Error> {
        if isSuccessMode {
            return Just(URL(string: "https://youtube.com")!).setFailureType(to: Error.self)
                .delay(for: .seconds(1), tolerance: nil, scheduler: RunLoop.main, options: nil)
                .eraseToAnyPublisher()
        } else {
            return Fail(error: TestError.failed).eraseToAnyPublisher()
        }
    }
}

class DummyPageRepository: PageRepositoryProtocol {
    var isSuccessMode: Bool = true
    
    init(isSuccessMode: Bool) {
        self.isSuccessMode = isSuccessMode
    }
    
    func savePage(_ page: PageEntity) -> AnyPublisher<PageEntity, Error> {
        if isSuccessMode {
            return Just(page)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        } else {
            return Fail(error: TestError.failed).eraseToAnyPublisher()
        }
    }
    
    func fetchPages(for pair: DDID) -> AnyPublisher<[PageEntity], Error> {
        return Fail(error: TestError.notImplemented).eraseToAnyPublisher()
    }
}

class DummyRawPageRepository: RawPageRepositoryProtocol {
    var isSuccessMode: Bool = true
    
    init(isSuccessMode: Bool) {
        self.isSuccessMode = isSuccessMode
    }
    
    func saveRawPage(_ rawPage: RawPageEntity) -> AnyPublisher<RawPageEntity, Error> {
        if isSuccessMode {
            return Just(rawPage)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        } else {
            return Fail(error: TestError.failed).eraseToAnyPublisher()
        }
    }
    
    func fetchRawPage(for path: String) -> AnyPublisher<RawPageEntity, Error> {
        return Fail(error: TestError.notImplemented).eraseToAnyPublisher()
    }
}


















