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

protocol PhotoPickerBottomSheetViewModelInput {
    func fetchPhotoAssets()
    func photoFrameDidSelect(_ index: Int)
    func photoDidSelected(_ items: [Int])
    func completeButtonDidTap()
}

protocol PhotoPickerBottomSheetViewModelOutput {
    var selectedPhotoFramePublisher: Published<PhotoFrameType?>.Publisher { get }
    var isReadyToCompose: Published<Bool>.Publisher { get }
    var composedResultPublisher: Published<PhotoComponentEntity?>.Publisher { get }
    var errorPublisher: Published<Error?>.Publisher { get }
}

typealias PhotoPickerBottomSheetViewModelProtocol = PhotoPickerBottomSheetViewModelInput & PhotoPickerBottomSheetViewModelOutput

class PhotoPickerBottomSheetViewModel: PhotoPickerBottomSheetViewModelProtocol {
    enum Errors: LocalizedError {
        case imageComposeError
        
        var errorDescription: String? {
            switch self {
            case .imageComposeError:
                return "이미지 합성에 실패했습니다."
            }
        }
    }
    
    var selectedPhotoFramePublisher: Published<PhotoFrameType?>.Publisher { self.$selectedPhotoFrame }
    var isReadyToCompose: Published<Bool>.Publisher { self.$readyToComposeState }
    var composedResultPublisher: Published<PhotoComponentEntity?>.Publisher { self.$composedResult }
    var errorPublisher: Published<Error?>.Publisher { self.$error }
    
    private(set) var photoFrames: [PhotoFrameType]
    private let imageUseCase: ImageUseCaseProtocol
    private let imageComposeUseCase: ImageComposeUseCaseProtocol
    
    private var cancellables = Set<AnyCancellable>()
    
    @Published private(set) var photoFetchResult: PHFetchResult<PHAsset>?
    @Published private(set) var selectedPhotos: [Int] = []
    @Published private var selectedPhotoFrame: PhotoFrameType?
    @Published private var readyToComposeState: Bool = false
    @Published private var composedResult: PhotoComponentEntity?
    @Published private var error: Error?
    
    init(imageUseCase: ImageUseCaseProtocol, imageComposeUseCase: ImageComposeUseCaseProtocol) {
        self.photoFrames = PhotoFrameType.allCases
        self.imageUseCase = imageUseCase
        self.imageComposeUseCase = imageComposeUseCase
        bind()
    }
    
    func fetchPhotoAssets() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [.init(key: "creationDate", ascending: false)]
        self.photoFetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchOptions)
    }
    
    func photoFrameDidSelect(_ index: Int) {
        self.selectedPhotoFrame = PhotoFrameType.allCases[index]
    }
    
    func photoDidSelected(_ items: [Int]) {
        guard let requiredPhotoCount = self.selectedPhotoFrame?.rawValue?.requiredPhotoCount,
              items.count <= requiredPhotoCount else { return }
        self.selectedPhotos = items
    }
    
    func completeButtonDidTap() {
        guard self.readyToComposeState,
              let photoFrame = self.selectedPhotoFrame else { return }
        
        let assets = self.selectedPhotos.compactMap { self.photoFetchResult?.object(at: $0) }
        
        let convertImagePublishers = assets.map { self.convertAssetToCIImage(asset: $0) }
        
        Publishers.MergeMany(convertImagePublishers)
            .collect()
            .map { $0.compactMap { $0 } }
            .flatMap { [weak self] images -> AnyPublisher<CIImage, Error> in
                guard let self = self else { return Fail(error: Errors.imageComposeError).eraseToAnyPublisher() }
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
                        let photoComponentEntity = PhotoComponentEntity(
                            frame: photoFrame.rawValue?.baseImage.extent ?? .zero,
                            scale: 1,
                            angle: 0,
                            aspectRatio: 1,
                            imageUrl: localUrl)
                        
                        self.composedResult = photoComponentEntity
                    })
                    .store(in: &self.cancellables)
            }
            .store(in: &self.cancellables)
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
    
    private func convertAssetToCIImage(asset: PHAsset) -> AnyPublisher<CIImage?, Never> {
        let imageRequestOptions = PHImageRequestOptions()
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
