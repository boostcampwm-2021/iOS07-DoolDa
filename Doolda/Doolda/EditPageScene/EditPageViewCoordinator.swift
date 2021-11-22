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
            let coreDataPersistenceService = CoreDataPersistenceService()
            let coreDataPageEntityPersistenceService = CoreDataPageEntityPersistenceService(
                coreDataPersistenceService: coreDataPersistenceService
            )
            
            let pairRepository = PairRepository(networkService: urlSessionNetworkService)
            let imageRepository = ImageRepository(
                fileManagerService: fileManagerPersistenceService,
                networkService: urlSessionNetworkService
            )
            let pageRepository = PageRepository(
                urlSessionNetworkService: urlSessionNetworkService,
                pageEntityPersistenceService: coreDataPageEntityPersistenceService
            )
            let rawPageRepository = RawPageRepository(
                networkService: urlSessionNetworkService,
                fileManagerPersistenceService: fileManagerPersistenceService
            )
            
            let imageUseCase = ImageUseCase(imageRepository: imageRepository)
            let editPageUseCase = EditPageUseCase(
                user: self.user,
                imageUseCase: imageUseCase,
                pageRepository: pageRepository,
                rawPageRepository: rawPageRepository,
                pairRepository: pairRepository
            )
            
            let editPageViewModel = EditPageViewModel(user: self.user, coordinator: self, editPageUseCase: editPageUseCase)
            
            let viewController = EditPageViewController(viewModel: editPageViewModel)
            self.presenter.pushViewController(viewController, animated: true)
        }
    }
    
    func editingPageSaved() {
        DispatchQueue.main.async {
            self.presenter.popViewController(animated: true)
        }
    }
    
    func editingPageCanceled() {
        DispatchQueue.main.async {
            self.presenter.popViewController(animated: true)
        }
    }
    
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
        let viewController = PhotoPickerBottomSheetViewController(
            photoPickerViewModel: photoPickerBottomSheetViewModel,
            delegate: delegatedViewController
        )
        
        self.presenter.topViewController?.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func editTextComponent(with textComponent: TextComponentEntity? = nil) {
        let delegatedViewController = self.presenter.topViewController as? EditPageViewController
        
        let textEditViewModel = TextEditViewModel(
            textUseCase: TextUseCase(),
            selectedTextComponent: textComponent)
        let viewController = TextEditViewController(
            textEditViewModel: textEditViewModel,
            delegate: delegatedViewController,
            widthRatioFromAbsolute: delegatedViewController?.widthRatioFromAbsolute,
            heightRatioFromAbsolute: delegatedViewController?.heightRatioFromAbsolute
        )
        
        self.presenter.topViewController?.present(viewController, animated: false, completion: nil)
    }
    
    func addStickerComponent() {
        let stickerUseCase = StickerUseCase()
        let stickerPickerBottomSheetViewModel = StickerPickerBottomSheetViewModel(stickerUseCase: stickerUseCase)
        let delegatedViewController = self.presenter.topViewController as? EditPageViewController
        let viewController = StickerPickerBottomSheetViewController(
            stickerPickerBottomSheetViewModel: stickerPickerBottomSheetViewModel,
            delegate: delegatedViewController
        )
        self.presenter.topViewController?.present(viewController, animated: false, completion: nil)
    }
    
    func changeBackgroundType() {
        let delegatedViewController = self.presenter.topViewController as? EditPageViewController
        let viewController = BackgroundTypePickerViewController(delegate: delegatedViewController)
        
        delegatedViewController?.present(viewController, animated: false, completion: nil)
    }
}
