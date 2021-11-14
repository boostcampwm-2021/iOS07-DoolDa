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
            let urlSessionNetworkService = URLSessionNetworkService()
            
            let dummyImageUseCase = DummyImageUseCase()
            let pageRepository = PageRepository(urlSessionNetworkService: urlSessionNetworkService)
            let dummyRawPageRepository = DummyRawPageRepository(isSuccessMode: true)
            
            let editPageUseCase = EditPageUseCase(imageUseCase: dummyImageUseCase, pageRepository: pageRepository, rawPageRepository: dummyRawPageRepository)
            let editPageViewModel = EditPageViewModel(user: self.user, coordinator: self, editPageUseCase: editPageUseCase)
            let viewController = EditPageViewController(viewModel: editPageViewModel)
            self.presenter.setViewControllers([viewController], animated: false)
        }
    }
    
    func editingPageSaved() {}
    func editingPageCanceled() {}
    
    func addPhotoComponent() {
        let fileManagerPersistenceService = FileManagerPersistenceService()
        let urlSessionNetworkService = URLSessionNetworkService()
        
        let imageRepository = ImageRepository(fileManagerService: fileManagerPersistenceService, networkService: urlSessionNetworkService)
        
        let imageUseCase = ImageUseCase(imageRepository: imageRepository)
        let imageComposeUseCaes = ImageComposeUseCase()
        
        let photoPickerBottomSheetViewModel = PhotoPickerBottomSheetViewModel(imageUseCase: imageUseCase, imageComposeUseCase: imageComposeUseCaes)
        
        let viewController = PhotoPickerBottomSheetViewController(photoPickerViewModel: photoPickerBottomSheetViewModel, photoPickerBottomSheetViewControllerDelegate: nil)
        
        self.presenter.topViewController?.present(viewController, animated: false, completion: nil)
    }
    
    func addTextComponent() {}
    
    func addStickerComponent() {}
}

enum TestError: Error {
    case notImplemented
    case failed
}

class DummyImageUseCase: ImageUseCaseProtocol {
    var isSuccessMode: Bool = true

    func saveLocal(image: CIImage) -> AnyPublisher<URL, Error> {
        return Just(URL(string: "https://naver.com")!).setFailureType(to: Error.self).eraseToAnyPublisher()
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
    
    func save(rawPage: RawPageEntity, at folder: String, with name: String) -> AnyPublisher<RawPageEntity, Error>  {
        if isSuccessMode {
            return Just(rawPage)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        } else {
            return Fail(error: TestError.failed).eraseToAnyPublisher()
        }
    }
    
    func fetch(at folder: String, with name: String) -> AnyPublisher<RawPageEntity, Error> {
        return Fail(error: TestError.notImplemented).eraseToAnyPublisher()
    }
}
