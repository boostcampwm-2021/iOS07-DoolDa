//
//  PhotoPickerBottomSheetViewModel.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/08.
//

import Combine
import CoreImage
import Foundation
import Photos

enum PhotoPickerBottomSheetViewModelError: LocalizedError {
    case failedToComposeImages
    case photoFrameNotSelected
    
    var errorDescription: String? {
        switch self {
        case .failedToComposeImages:
            return "이미지 합성에 실패했습니다."
        case .photoFrameNotSelected:
            return "사진 프레임이 선택되지 않았습니다."
        }
    }
}

protocol PhotoPickerBottomSheetViewModelInput {
    func photoFrameDidSelect(_ index: Int)
    func photoDidSelected(_ items: [Int])
    func photoFrameCellDidTap()
    func nextButtonDidTap()
    func completeButtonDidTap()
    func photoAccessPermissionDidChange(_ authorizationStatus: PHAuthorizationStatus)
}

protocol PhotoPickerBottomSheetViewModelOutput {
    var photoFrames: [PhotoFrameType] { get }
    var selectedPhotos: [Int] { get }
    var photoFetchResultWithChangeDetails: PhotoFetchResultWithChangeDetails? { get }
    var selectedPhotosPublisher: Published<[Int]>.Publisher { get }
    var photoFetchResultWithChangeDetailsPublisher: Published<PhotoFetchResultWithChangeDetails?>.Publisher { get }
    var selectedPhotoFramePublisher: Published<PhotoFrameType?>.Publisher { get }
    var isReadyToSelectPhoto: Published<Bool>.Publisher { get }
    var isReadyToComposePhoto: Published<Bool>.Publisher { get }
    var isPhotoAccessiblePublisher: Published<Bool?>.Publisher { get }
    var composedResultPublisher: Published<PhotoComponentEntity?>.Publisher { get }
    var errorPublisher: Published<Error?>.Publisher { get }
}

typealias PhotoPickerBottomSheetViewModelProtocol = PhotoPickerBottomSheetViewModelInput & PhotoPickerBottomSheetViewModelOutput
typealias PhotoFetchResultWithChangeDetails = (photoFetchResult: PHFetchResult<PHAsset>, changeDetails: PHFetchResultChangeDetails<PHAsset>?)

class PhotoPickerBottomSheetViewModel: NSObject, PhotoPickerBottomSheetViewModelProtocol {
    var selectedPhotosPublisher: Published<[Int]>.Publisher { self.$selectedPhotos }
    var photoFetchResultWithChangeDetailsPublisher: Published<PhotoFetchResultWithChangeDetails?>.Publisher { self.$photoFetchResultWithChangeDetails }
    var selectedPhotoFramePublisher: Published<PhotoFrameType?>.Publisher { self.$selectedPhotoFrame }
    var isReadyToSelectPhoto: Published<Bool>.Publisher { self.$readyToSelectPhotoState }
    var isReadyToComposePhoto: Published<Bool>.Publisher { self.$readyToComposeState }
    var isPhotoAccessiblePublisher: Published<Bool?>.Publisher { self.$photoAccessState }
    var composedResultPublisher: Published<PhotoComponentEntity?>.Publisher { self.$composedResult }
    var errorPublisher: Published<Error?>.Publisher { self.$error }
    
    private(set) var photoFrames: [PhotoFrameType]
    private let imageUseCase: ImageUseCaseProtocol
    private let imageComposeUseCase: ImageComposeUseCaseProtocol
    
    private var cancellables = Set<AnyCancellable>()
    
    @Published private(set) var photoFetchResultWithChangeDetails: PhotoFetchResultWithChangeDetails?
    @Published private(set) var selectedPhotos: [Int] = []
    @Published private var selectedPhotoFrame: PhotoFrameType?
    @Published private var photoAccessState: Bool?
    @Published private var readyToSelectPhotoState: Bool = false
    @Published private var readyToComposeState: Bool = false
    @Published private var composedResult: PhotoComponentEntity?
    @Published private var error: Error?
    
    init(imageUseCase: ImageUseCaseProtocol, imageComposeUseCase: ImageComposeUseCaseProtocol) {
        self.photoFrames = PhotoFrameType.allCases
        self.imageUseCase = imageUseCase
        self.imageComposeUseCase = imageComposeUseCase
        super.init()
        PHPhotoLibrary.shared().register(self)
        bind()
    }
    
    func fetchPhotoAssets() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [.init(key: "creationDate", ascending: false)]
        fetchOptions.includeAllBurstAssets = true
        fetchOptions.includeHiddenAssets = false
        fetchOptions.includeAssetSourceTypes = [.typeUserLibrary]
        self.photoFetchResultWithChangeDetails = (PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchOptions), nil)
    }
    
    func photoFrameDidSelect(_ index: Int) {
        self.selectedPhotoFrame = PhotoFrameType.allCases[index]
    }
    
    func photoDidSelected(_ items: [Int]) {
        guard let requiredPhotoCount = self.selectedPhotoFrame?.rawValue?.requiredPhotoCount,
              items.count <= requiredPhotoCount else { return }
        self.selectedPhotos = items
    }
    
    func photoFrameCellDidTap() {
        selectPhotoFrame()
    }
    
    func nextButtonDidTap() {
        selectPhotoFrame()
    }
    
    func completeButtonDidTap() {
        guard self.readyToComposeState,
              let photoFrame = self.selectedPhotoFrame else { return }
        
        let assets = self.selectedPhotos.compactMap { self.photoFetchResultWithChangeDetails?.photoFetchResult.object(at: $0) }
        
        let convertImagePublishers = assets.map { self.convertAssetToCIImage(asset: $0) }
        
        Publishers.MergeMany(convertImagePublishers)
            .collect()
            .map { $0.compactMap { $0 } }
            .flatMap { [weak self] images -> AnyPublisher<CIImage, Error> in
                guard let self = self else {
                    return Fail(error: PhotoPickerBottomSheetViewModelError.failedToComposeImages).eraseToAnyPublisher()
                }
                return self.imageComposeUseCase.compose(photoFrameType: photoFrame, images: images)
            }
            .sink { [weak self] completion in
                guard case .failure(let error) = completion else { return }
                self?.error = error
            } receiveValue: { [weak self] composedImage in
                guard let self = self else { return }
                self.imageUseCase.saveLocal(image: composedImage)
                    .sink(receiveCompletion: { completion in
                        guard case .failure(let error) = completion else { return }
                        self.error = error
                    }, receiveValue: { localUrl in
                        guard let imageSize = photoFrame.rawValue?.baseImage.extent.size else { return }
                        let componentOrigin = CGPoint(x: 850 - imageSize.width/2, y: 1500 - imageSize.height/2)
                        let photoComponentEntity = PhotoComponentEntity(
                            frame: CGRect(origin: componentOrigin, size: imageSize),
                            scale: 1,
                            angle: 0,
                            aspectRatio: 1,
                            imageUrl: localUrl
                        )
                        
                        self.composedResult = photoComponentEntity
                    })
                    .store(in: &self.cancellables)
            }
            .store(in: &self.cancellables)
    }
    
    func photoAccessPermissionDidChange(_ authorizationStatus: PHAuthorizationStatus) {
        guard authorizationStatus == .authorized || authorizationStatus == .limited else { return }
        self.photoAccessState = true
        selectPhotoFrame()
    }
    
    private func bind() {
        self.$selectedPhotos
            .sink { [weak self] photos in
                guard let self = self else { return }
                self.readyToComposeState = self.imageComposeUseCase.isComposable(
                    photoFrameType: self.selectedPhotoFrame,
                    numberOfPhotos: photos.count
                )
            }
            .store(in: &self.cancellables)
    }
    
    private func selectPhotoFrame() {
        guard self.selectedPhotoFrame != nil else {
            return self.error = PhotoPickerBottomSheetViewModelError.photoFrameNotSelected
        }
        
        let authorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        guard authorizationStatus == .authorized || authorizationStatus == .limited else {
            return self.photoAccessState = false
        }
        
        self.fetchPhotoAssets()
        
        self.readyToSelectPhotoState = true
    }
    
    private func convertAssetToCIImage(asset: PHAsset) -> AnyPublisher<CIImage?, Never> {
        let imageRequestOptions = PHImageRequestOptions()
        imageRequestOptions.isNetworkAccessAllowed = true
        imageRequestOptions.deliveryMode = .highQualityFormat
        
        return Future<CIImage?, Never> { promise in
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
}

extension PhotoPickerBottomSheetViewModel: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let photoFetchResult = self.photoFetchResultWithChangeDetails?.photoFetchResult,
              let changes = changeInstance.changeDetails(for: photoFetchResult) else { return }
        
        self.photoFetchResultWithChangeDetails = (changes.fetchResultAfterChanges, changes)
    }
}
