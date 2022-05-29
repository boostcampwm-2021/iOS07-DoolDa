//
//  PhotoPickerBottomSheetViewController.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/09.
//

import Combine
import Photos
import UIKit

import SnapKit

protocol PhotoPickerBottomSheetViewControllerDelegate: AnyObject {
    func composedPhotoDidMake(_ photoComponentEntity: PhotoComponentEntity)
}

final class PhotoPickerBottomSheetViewController: BottomSheetViewController {
    
    // MARK: - Subviews
    
    private lazy var bottomSheetTitle: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .dooldaLabel
        label.text = "사진 추가"
        return label
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setImage(.xmark, for: .normal)
        return button
    }()
    
    private lazy var topStack: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [
                bottomSheetTitle,
                closeButton
            ]
        )
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    private lazy var contentFrame: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var framePicker: CarouselView = {
        let carousel = CarouselView(
            carouselDelegate: self,
            carouselCollectionViewDataSource: self,
            carouselCollectionViewDelegate: self
        )
        carousel.itemInterval = 25
        carousel.insetX = 100
        return carousel
    }()
    
    private lazy var activityIndicator: CustomActivityIndicator = {
        let customActivityIndicator = CustomActivityIndicator(subTitle: "이미지 합성중이에요!🦔🦔", loadingImage: .hedgehogWriting)
        customActivityIndicator.isHidden = true
        return customActivityIndicator
    }()
    
    private lazy var photoPickerCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 0.5
        flowLayout.minimumInteritemSpacing = 0.5
        flowLayout.sectionInset = .zero

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.register(
            PhotoPickerCollectionViewCell.self,
            forCellWithReuseIdentifier: PhotoPickerCollectionViewCell.photoPickerCellIdentifier
        )
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    private lazy var nextButton: UIButton = {
        let button = DooldaButton()
        button.setTitleColor(.dooldaLabel, for: .normal)
        button.backgroundColor = .dooldaHighlighted
        button.setTitle("다음", for: .normal)
        button.isEnabled = false
        return button
    }()
    
    // MARK: - Private Properties

    private var viewModel: PhotoPickerBottomSheetViewModelProtocol!
    private var cancellables = Set<AnyCancellable>()
    private var currentContentView: UIView?
    private weak var delegate: PhotoPickerBottomSheetViewControllerDelegate?
    
    // MARK: - Initializers
    
    convenience init(
        photoPickerViewModel: PhotoPickerBottomSheetViewModelProtocol,
        delegate: PhotoPickerBottomSheetViewControllerDelegate?
    ) {
        self.init(nibName: nil, bundle: nil)
        self.viewModel = photoPickerViewModel
        self.delegate = delegate
    }
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        self.configureFont()
        bindUI()
        bindViewModel()
        
        setContentView(self.framePicker)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: - Helpers
    
    private func configureUI() {
        self.detent = .smallLarge
        self.body.backgroundColor = .dooldaBackground
        
        self.body.addSubview(self.topStack)
        self.topStack.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(16)
        }
        
        self.body.addSubview(self.contentFrame)
        self.contentFrame.snp.makeConstraints { make in
            make.top.equalTo(self.topStack.snp.bottom).offset(10)
            make.leading.trailing.equalTo(self.body)
        }
        
        self.body.addSubview(self.nextButton)
        self.nextButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(44)
            make.bottom.equalToSuperview().offset(-32)
            make.top.equalTo(self.contentFrame.snp.bottom).offset(10).priority(.low)
        }
        
        self.view.addSubview(self.activityIndicator)
        self.activityIndicator.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func configureFont() {
        self.bottomSheetTitle.font = .systemFont(ofSize: 16)
        self.nextButton.titleLabel?.font = .systemFont(ofSize: 16)
    }
    
    private func bindUI() {
        self.nextButton.publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.currentContentView == self.framePicker {
                    self.viewModel.nextButtonDidTap()
                } else if self.currentContentView == self.photoPickerCollectionView {
                    self.activityIndicator.startAnimating()
                    self.viewModel.completeButtonDidTap()
                }
            }
            .store(in: &self.cancellables)
        
        self.closeButton.publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.dismiss(animated: true, completion: nil)
            }
            .store(in: &self.cancellables)
    }
    
    private func bindViewModel() {
        self.viewModel.isPhotoAccessiblePublisher
            .compactMap { $0 }
            .sink { [weak self] result in
                guard result.toggled else { return }
                self?.requestAuthorization()
            }
            .store(in: &self.cancellables)
        
        self.viewModel.isReadyToSelectPhoto
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard result,
                      let self = self else { return }
                self.setContentView(self.photoPickerCollectionView)
                self.nextButton.setTitle("완료", for: .normal)
                self.nextButton.isEnabled = false
            }
            .store(in: &self.cancellables)
                   
        self.viewModel.isReadyToComposePhoto
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                self?.nextButton.isEnabled = self?.currentContentView == self?.framePicker ||
                (self?.currentContentView == self?.photoPickerCollectionView && result)
            }
            .store(in: &self.cancellables)
        
        self.viewModel.composedResultPublisher
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] photoComponentEntity in
                self?.delegate?.composedPhotoDidMake(photoComponentEntity)
                self?.activityIndicator.stopAnimating()
                self?.dismiss(animated: true, completion: nil)
            }
            .store(in: &self.cancellables)
        
        self.viewModel.selectedPhotosPublisher
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] selectedPhotos in
                self?.photoPickerCollectionView.reloadItems(at: selectedPhotos.map { IndexPath(item: $0, section: 0) })
            }
            .store(in: &self.cancellables)
        
        self.viewModel.selectedPhotoFramePublisher
            .compactMap { $0 }
            .sink { [weak self] _ in
                self?.nextButton.isEnabled = true
            }
            .store(in: &self.cancellables)
        
        self.viewModel.photoFetchResultWithChangeDetailsPublisher
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _, fetchResultChangeDetails in
                guard let self = self else { return }
                
                if let changed = fetchResultChangeDetails?.changedIndexes, changed.isEmpty.toggled {
                    self.photoPickerCollectionView.reloadItems(at: changed.map { IndexPath(item: $0, section:0) })
                } else {
                    self.photoPickerCollectionView.reloadData()
                }
            }
            .store(in: &self.cancellables)
        
        self.viewModel.errorPublisher
            .compactMap { $0 }
            .sink { [weak self] error in
                let alert = UIAlertController.defaultAlert(title: "알림", message: error.localizedDescription) { _ in
                    self?.dismiss(animated: true, completion: nil)
                }
                
                self?.present(alert, animated: true, completion: nil)
            }
            .store(in: &self.cancellables)
        
        NotificationCenter.default.publisher(for: GlobalFontUseCase.Notifications.globalFontDidSet, object: nil)
            .sink { [weak self] _ in
                self?.configureFont()
            }
            .store(in: &self.cancellables)
    }
    
    // MARK: - Private Method
    
    private func setContentView(_ content: UIView) {
        self.currentContentView?.snp.removeConstraints()
        self.currentContentView?.removeFromSuperview()
        self.currentContentView = content
        
        self.contentFrame.addSubview(content)
        content.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func requestAuthorization() {
        let authorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        if authorizationStatus == .denied {
            self.requestPermissionToAccessPhoto()
        } else {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
                self?.viewModel.photoAccessPermissionDidChange(status)
            }
        }
    }
    
    private func requestPermissionToAccessPhoto() {
        let alert = UIAlertController.selectAlert(
            title: "사진 접근 권한 요청",
            message: "사진 접근 권한이 없습니다.\n'설정'을 눌러\n'사진' 접근을 허용해주세요.",
            leftActionTitle: "취소",
            rightActionTitle: "설정") { _ in
                guard let url = URL(string: UIApplication.openSettingsURLString),
                      UIApplication.shared.canOpenURL(url) else { return }

                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        
        self.present(alert, animated: true, completion: nil)
    }
}

extension PhotoPickerBottomSheetViewController: CarouselViewDelegate {
    func selectedItemDidChange(_ index: Int) {
        self.viewModel.photoFrameDidSelect(index)
    }
}

extension PhotoPickerBottomSheetViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        if collectionView == self.photoPickerCollectionView {
            guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return .zero }
            let cellSize = collectionView.bounds.width / 3 - layout.minimumInteritemSpacing
            return CGSize(width: cellSize, height: cellSize)
        } else {
            return CGSize(
                width: collectionView.bounds.width - (collectionView.contentInset.left + collectionView.contentInset.right),
                height: collectionView.bounds.height
            )
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.photoPickerCollectionView {
            return self.viewModel.photoFetchResultWithChangeDetails?.photoFetchResult.count ?? 0
        } else {
            return self.viewModel.photoFrames.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: UICollectionViewCell
        
        if collectionView == self.photoPickerCollectionView {
            cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PhotoPickerCollectionViewCell.photoPickerCellIdentifier,
                for: indexPath
            )
            
            if let photoPickerCollectionViewCell = cell as? PhotoPickerCollectionViewCell,
               let imageAsset = self.viewModel.photoFetchResultWithChangeDetails?.photoFetchResult.object(at: indexPath.item) {
                photoPickerCollectionViewCell.display(imageAsset)
                
                if self.viewModel.selectedPhotos.contains(indexPath.item),
                   let target = self.viewModel.selectedPhotos.enumerated().first(where: { $0.element == indexPath.item }) {
                    photoPickerCollectionViewCell.select(order: target.offset + 1)
                }
            }
        } else {
            cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PhotoFrameCollectionViewCell.photoPickerFrameCellIdentifier,
                for: indexPath
            )
            
            if let photoFrameCollectionViewCell = cell as? PhotoFrameCollectionViewCell,
               let baseImage = self.viewModel.photoFrames[indexPath.item].rawValue?.baseImage,
               let displayName = self.viewModel.photoFrames[indexPath.item].rawValue?.displayName {
                photoFrameCollectionViewCell.display(baseImage, displayName)
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.photoPickerCollectionView {
            var selectedPhotos = self.viewModel.selectedPhotos
            
            if selectedPhotos.contains(indexPath.item),
               let target = selectedPhotos.enumerated().first(where: { $0.element == indexPath.item }) {
                self.viewModel.photoDidSelected(selectedPhotos.filter({ $0 != target.element }))
                self.photoPickerCollectionView.reloadItems(at: [indexPath])
            } else {
                selectedPhotos.append(indexPath.item)
                self.viewModel.photoDidSelected(selectedPhotos)
            }
        } else {
            self.viewModel.photoFrameCellDidTap()
        }
    }
}
