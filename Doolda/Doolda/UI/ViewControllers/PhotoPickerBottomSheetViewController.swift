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
    func composedPhotoDidMake(_ url: URL)
}

final class PhotoPickerBottomSheetViewController: BottomSheetViewController {
    
    // MARK: - Subviews
    
    private lazy var bottomSheetTitle: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Dovemayo", size: 16)
        label.textColor = .dooldaLabel
        label.text = "사진 추가"
        return label
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
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
        carousel.itemInterval = 50.0
        return carousel
    }()
    
    private lazy var activityIndicator: CustomActivityIndicator = {
        let customActivityIndicator = CustomActivityIndicator(subTitle: "이미지 합성중이에요!🦔🦔")
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
        var configuration = UIButton.Configuration.filled()
        configuration.cornerStyle = .capsule
        configuration.baseForegroundColor = .dooldaLabel
        configuration.baseBackgroundColor = .dooldaHighlighted
        configuration.attributedTitle = AttributedString("다음", attributes: self.fontContainer)
        let button = UIButton(configuration: configuration)
        button.isEnabled = false
        return button
    }()
    
    // MARK: - Private Properties
    
    private var fontContainer: AttributeContainer {
        var container = AttributeContainer()
        container.font = UIFont(name: "Dovemayo", size: 16)
        return container
    }
    
    private var viewModel: PhotoPickerBottomSheetViewModel?
    private weak var delegate: PhotoPickerBottomSheetViewControllerDelegate?

    @Published private var photos: PHFetchResult<PHAsset>?
    
    private var cancellables = Set<AnyCancellable>()
    private var currentContentView: UIView?
    
    // MARK: - Initializers
    
    convenience init(
        photoPickerViewModel: PhotoPickerBottomSheetViewModel,
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
        bindUI()
        
        setContentView(self.framePicker)
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
    
    private func bindUI() {
        guard let viewModel = viewModel else { return }
        
        self.nextButton.publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.currentContentView == self.framePicker {
                    self.fetchPhotos()
                    self.setContentView(self.photoPickerCollectionView)
                    self.nextButton.configuration?.attributedTitle = AttributedString("완료", attributes: self.fontContainer)
                    self.nextButton.isEnabled = false
                } else if self.currentContentView == self.photoPickerCollectionView {
                    self.activityIndicator.startAnimating()
                    
                    let assets = viewModel.selectedPhotos.compactMap { self.photos?.object(at: $0) }
                    
                    self.convertAssetToImage(assets: assets)
                        .sink { ciImages in
                            self.viewModel?.completeButtonDidTap(ciImages)
                        }
                        .store(in: &self.cancellables)
                }
            }
            .store(in: &self.cancellables)
        
        self.closeButton.publisher(for: .touchUpInside)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.dismiss(animated: true, completion: nil)
            }
            .store(in: &self.cancellables)
        
        viewModel.isReadyToCompose
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                self?.nextButton.isEnabled = self?.currentContentView == self?.framePicker ||
                (self?.currentContentView == self?.photoPickerCollectionView && result)
            }
            .store(in: &self.cancellables)
        
        viewModel.composedResultPublisher
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] url in
                self?.delegate?.composedPhotoDidMake(url)
                self?.activityIndicator.stopAnimating()
                self?.dismiss(animated: true, completion: nil)
            }
            .store(in: &self.cancellables)
        
        viewModel.$selectedPhotos
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] _ in
                self?.photoPickerCollectionView.reloadData()
            }
            .store(in: &self.cancellables)
        
        viewModel.selectedPhotoFramePublisher
            .compactMap { $0 }
            .sink { [weak self] _ in
                self?.nextButton.isEnabled = true
            }
            .store(in: &cancellables)
        
        viewModel.errorPublisher
            .compactMap { $0 }
            .sink { [weak self] error in
                let alert = UIAlertController.defaultAlert(title: "알림", message: error.localizedDescription) { _ in
                    self?.dismiss(animated: true, completion: nil)
                }
                
                self?.present(alert, animated: true, completion: nil)
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
    
    private func fetchPhotos() {
        self.checkPhotoAccessPermission { result in
            guard result else { return }
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [.init(key: "creationDate", ascending: false)]
            self.photos = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchOptions)
        }
    }
    
    private func checkPhotoAccessPermission(completionHandler: @escaping (Bool) -> Void) {
        guard PHPhotoLibrary.authorizationStatus(for: .readWrite) != .authorized else {
            return completionHandler(true)
        }
        
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            completionHandler(status == .authorized)
        }
    }
    
    private func convertAssetToImage(assets: [PHAsset]) -> AnyPublisher<[CIImage], Never> {
        let imageRequestOptions = PHImageRequestOptions()
        imageRequestOptions.deliveryMode = .highQualityFormat
        
        let imageRequestPublishers = assets.map { asset in
            Future<CIImage?, Never> { promise in
                PHImageManager.default().requestImage(
                    for: asset,
                    targetSize: PHImageManagerMaximumSize,
                    contentMode: .aspectFill,
                    options: imageRequestOptions
                ) { image, _ in
                    guard let cgImage = image?.cgImage else { return promise(.success(nil)) }
                    promise(.success(CIImage(cgImage: cgImage)))
                }
            }
            .eraseToAnyPublisher()
        }
        
        return Future<[CIImage], Never> { promise in
            Publishers.MergeMany(imageRequestPublishers)
                .collect()
                .map { images in
                    images.compactMap { $0 }
                }
                .sink { images in
                    promise(.success(images))
                }
                .store(in: &self.cancellables)
        }
        .eraseToAnyPublisher()
    }
}

extension PhotoPickerBottomSheetViewController: CarouselViewDelegate {
    func selectedItemDidChange(_ index: Int) {
        self.viewModel?.photoFrameDidSelect(index)
    }
}

extension PhotoPickerBottomSheetViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        if collectionView === self.photoPickerCollectionView {
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
        if collectionView === self.photoPickerCollectionView {
            return self.photos?.count ?? 0
        } else {
            return self.viewModel?.photoFrames.count ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: UICollectionViewCell
        
        if collectionView === self.photoPickerCollectionView {
            cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PhotoPickerCollectionViewCell.photoPickerCellIdentifier,
                for: indexPath
            )
            
            if let selectedPhotos = self.viewModel?.selectedPhotos,
               let photoPickerCollectionViewCell = cell as? PhotoPickerCollectionViewCell,
               let imageAsset = self.photos?.object(at: indexPath.item) {
                photoPickerCollectionViewCell.fill(imageAsset)
                
                if selectedPhotos.contains(indexPath.item),
                   let target = selectedPhotos.enumerated().first(where: { $0.element == indexPath.item }) {
                    photoPickerCollectionViewCell.select(order: target.offset + 1)
                }
            }
        } else {
            cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: PhotoFrameCollectionViewCell.photoPickerFrameCellIdentifier,
                for: indexPath
            )
            
            if let photoFrameCollectionViewCell = cell as? PhotoFrameCollectionViewCell,
               let baseImage = self.viewModel?.photoFrames[indexPath.item].rawValue?.baseImage {
                photoFrameCollectionViewCell.fill(baseImage)
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView === self.photoPickerCollectionView {
            guard var selectedPhotos = self.viewModel?.selectedPhotos else { return }
            
            if selectedPhotos.contains(indexPath.item),
               let target = selectedPhotos.enumerated().first(where: { $0.element == indexPath.item }) {
                self.viewModel?.photoDidSelected(selectedPhotos.filter({ $0 != target.element }))
            } else {
                selectedPhotos.append(indexPath.item)
                self.viewModel?.photoDidSelected(selectedPhotos)
            }
        }
    }
}
