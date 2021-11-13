//
//  PhotoPickerBottomSheetViewModel.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/08.
//

import Combine
import CoreImage
import Foundation

protocol PhotoPickerBottomSheetViewModelInput {
    func photoFrameDidSelect(_ index: Int)
    func photoDidSelected(_ items: [Int])
    func completeButtonDidTap(_ photos: [CIImage])
}

protocol PhotoPickerBottomSheetViewModelOutput {
    var selectedPhotoFramePublisher: Published<PhotoFrameType?>.Publisher { get }
    var isReadyToCompose: Published<Bool>.Publisher { get }
    var composedResultPublisher: Published<URL?>.Publisher { get }
    var errorPublisher: Published<Error?>.Publisher { get }
}

typealias PhotoPickerBottomSheetViewModelProtocol = PhotoPickerBottomSheetViewModelInput & PhotoPickerBottomSheetViewModelOutput

class PhotoPickerBottomSheetViewModel: PhotoPickerBottomSheetViewModelProtocol {
    var selectedPhotoFramePublisher: Published<PhotoFrameType?>.Publisher { self.$selectedPhotoFrame }
    var isReadyToCompose: Published<Bool>.Publisher { self.$readyToComposeState }
    var composedResultPublisher: Published<URL?>.Publisher { self.$composedResult }
    var errorPublisher: Published<Error?>.Publisher { self.$error }
    
    private(set) var photoFrames: [PhotoFrameType]
    private let imageUseCase: ImageUseCaseProtocol
    private let imageComposeUseCase: ImageComposeUseCaseProtocol
    
    private var cancellables = Set<AnyCancellable>()
    
    @Published private(set) var selectedPhotos: [Int] = []
    @Published private var selectedPhotoFrame: PhotoFrameType?
    @Published private var readyToComposeState: Bool = false
    @Published private var composedResult: URL?
    @Published private var error: Error?
    
    init(imageUseCase: ImageUseCaseProtocol, imageComposeUseCase: ImageComposeUseCaseProtocol) {
        self.photoFrames = PhotoFrameType.allCases
        self.imageUseCase = imageUseCase
        self.imageComposeUseCase = imageComposeUseCase
        bind()
    }
    
    func photoFrameDidSelect(_ index: Int) {
        // FIXME : PhotoFrameType 변경에 따라 수정필요
        self.selectedPhotoFrame = PhotoFrameType.allCases[index]
    }
    
    func photoDidSelected(_ items: [Int]) {
        guard let requiredPhotoCount = self.selectedPhotoFrame?.rawValue?.requiredPhotoCount,
              items.count <= requiredPhotoCount else { return }
        self.selectedPhotos = items
    }
    
    func completeButtonDidTap(_ photos: [CIImage]) {
        guard self.readyToComposeState,
              let selectedPhotoFrame = selectedPhotoFrame else { return }
        
        self.imageComposeUseCase.compose(photoFrameType: selectedPhotoFrame, images: photos)
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
                        self.composedResult = localUrl
                    })
                    .store(in: &self.cancellables)
            }
            .store(in: &self.cancellables)
    }
    
    private func bind() {
        self.$selectedPhotos
            .sink { [weak self] photos in
                guard let self = self else { return }
                self.readyToComposeState = self.imageComposeUseCase.isComposable(photoFrameType: self.selectedPhotoFrame, numberOfPhotos: photos.count)
            }
            .store(in: &self.cancellables)
    }
}
