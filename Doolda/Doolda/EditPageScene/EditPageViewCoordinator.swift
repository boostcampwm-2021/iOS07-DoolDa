//
//  EditPageViewCoordinator.swift
//  Doolda
//
//  Created by 김민주 on 2021/11/09.
//

import Combine
import UIKit

final class EditPageViewCoordinator: BaseCoordinator {
    
    // MARK: - Nested Enums
    
    enum Notifications {
        static let editPageSaved = Notification.Name("editPageSaved")
        static let editingPageCanceled = Notification.Name("editingPageCanceled")
        static let addPhotoComponent = Notification.Name("addPhotoComponent")
        static let editTextComponent = Notification.Name("editTextComponent")
        static let addStickerComponent = Notification.Name("addStickerComponent")
        static let changeBackgroundType = Notification.Name("changeBackgroundType")
    }
    
    enum Keys {
        static let textComponent = "textComponent"
    }
    
    // MARK: - Private Properties
    
    private let user: User
    private let pageEntity: PageEntity?
    private let rawPageEntity: RawPageEntity?
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Initializers
    
    init(
        identifier: UUID,
        presenter: UINavigationController,
        user: User,
        pageEntity: PageEntity? = nil,
        rawPageEntity: RawPageEntity? = nil
    ) {
        self.user = user
        self.pageEntity = pageEntity
        self.rawPageEntity = rawPageEntity
        super.init(identifier: identifier, presenter: presenter)
        self.bind()
    }
    
    // MARK: - Helpers
    
    private func bind() {
        NotificationCenter.default.publisher(for: Notifications.editTextComponent, object: nil)
            .map { $0.userInfo?[EditPageViewCoordinator.Keys.textComponent] as? TextComponentEntity }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] textComponent in
                self?.editTextComponent(with: textComponent)
            }
            .store(in: &self.cancellables)
    }
    
    // MARK: - Public Methods
    
    func start() {
        DispatchQueue.main.async {
            let fileManagerPersistenceService = FileManagerPersistenceService.shared
            let firebaseNetworkService = FirebaseNetworkService.shared
            let coreDataPersistenceService = CoreDataPersistenceService.shared
            let coreDataPageEntityPersistenceService = CoreDataPageEntityPersistenceService(
                coreDataPersistenceService: coreDataPersistenceService
            )
            
            let pairRepository = PairRepository(networkService: firebaseNetworkService)
            let imageRepository = ImageRepository(
                fileManagerService: fileManagerPersistenceService,
                networkService: firebaseNetworkService
            )
            let pageRepository = PageRepository(
                networkService: FirebaseNetworkService.shared,
                pageEntityPersistenceService: coreDataPageEntityPersistenceService
            )
            let rawPageRepository = RawPageRepository(
                networkService: FirebaseNetworkService.shared,
                coreDataPageEntityPersistenceService: coreDataPageEntityPersistenceService,
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
            let firebaseMessageUseCase = FirebaseMessageUseCase.default
            
            let editPageViewModel = EditPageViewModel(
                sceneId: self.identifier,
                user: self.user,
                pageEntity: self.pageEntity,
                rawPageEntity: self.rawPageEntity,
                editPageUseCase: editPageUseCase,
                firebaseMessageUseCase: firebaseMessageUseCase
            )
            
            editPageViewModel.editPageSaved
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    self?.editingPageSaved()
                }
                .store(in: &self.cancellables)
            
            editPageViewModel.editPageCanceled
                .sink { [weak self] _ in
                    self?.editingPageCanceled()
                }
                .store(in: &self.cancellables)
            
            editPageViewModel.addPhotoComponent
                .sink { [weak self] _ in
                    self?.addPhotoComponent()
                }
                .store(in: &self.cancellables)
            
            editPageViewModel.editTextComponent
                .sink { [weak self] textComponentEntity in
                    self?.editTextComponent(with: textComponentEntity)
                }
                .store(in: &self.cancellables)
            
            editPageViewModel.addStrickerComponent
                .sink { [weak self] _ in
                    self?.addStickerComponent()
                }
                .store(in: &self.cancellables)
            
            editPageViewModel.changeBackGroundType
                .sink { [weak self] _ in
                    self?.changeBackgroundType()
                }
                .store(in: &self.cancellables)
            
            let viewController = EditPageViewController(viewModel: editPageViewModel)
            self.presenter.pushViewController(viewController, animated: true)
        }
    }
    
    // MARK: - Private Methods
    
    private func editingPageSaved() {
        self.presenter.popViewController(animated: true)
    }
    
    private func editingPageCanceled() {
        self.presenter.popViewController(animated: true)
    }
    
    private func addPhotoComponent() {
        let fileManagerPersistenceService = FileManagerPersistenceService.shared
        let firebaseNetworkService = FirebaseNetworkService.shared
        
        let imageRepository = ImageRepository(fileManagerService: fileManagerPersistenceService, networkService: firebaseNetworkService)
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
        
        self.presenter.topViewController?.present(viewController, animated: false, completion: nil)
    }
    
    private func editTextComponent(with textComponent: TextComponentEntity? = nil) {
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
    
    private func addStickerComponent() {
        let stickerUseCase = StickerUseCase()
        let stickerPickerBottomSheetViewModel = StickerPickerBottomSheetViewModel(stickerUseCase: stickerUseCase)
        let delegatedViewController = self.presenter.topViewController as? EditPageViewController
        let viewController = StickerPickerBottomSheetViewController(
            stickerPickerBottomSheetViewModel: stickerPickerBottomSheetViewModel,
            delegate: delegatedViewController
        )
        self.presenter.topViewController?.present(viewController, animated: false, completion: nil)
    }
    
    private func changeBackgroundType() {
        let delegatedViewController = self.presenter.topViewController as? EditPageViewController
        let viewController = BackgroundTypePickerViewController(delegate: delegatedViewController)
        
        delegatedViewController?.present(viewController, animated: false, completion: nil)
    }
}
