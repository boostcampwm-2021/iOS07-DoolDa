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
            let fileManagerPersistenceService = FileManagerPersistenceService()
            let urlSessionNetworkService = URLSessionNetworkService()
            
            let imageRepository = ImageRepository(fileManagerService: fileManagerPersistenceService, networkService: urlSessionNetworkService)
            let pageRepository = PageRepository(urlSessionNetworkService: urlSessionNetworkService)
            let rawPageRepository = RawPageRepository(networkService: urlSessionNetworkService)
            
            let imageUseCase = ImageUseCase(imageRepository: imageRepository)
            let editPageUseCase = EditPageUseCase(
                imageUseCase: imageUseCase,
                pageRepository: pageRepository,
                rawPageRepository: rawPageRepository
            )
            
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
        
        let photoPickerBottomSheetViewModel = PhotoPickerBottomSheetViewModel(
            imageUseCase: imageUseCase,
            imageComposeUseCase: imageComposeUseCaes
        )
        
        let delegatedViewController = self.presenter.topViewController as? EditPageViewController
        let viewController = PhotoPickerBottomSheetViewController(photoPickerViewModel: photoPickerBottomSheetViewModel, delegate: delegatedViewController)
        
        self.presenter.topViewController?.present(viewController, animated: false, completion: nil)
    }
    
    func addTextComponent() {}
    
    func addStickerComponent() {}
    
    func changeBackgroundType() {
        let delegatedViewController = self.presenter.topViewController as? EditPageViewController
        let viewController = BackgroundTypePickerViewController(delegate: delegatedViewController)
        
        delegatedViewController?.present(viewController, animated: false, completion: nil)
    }
}
