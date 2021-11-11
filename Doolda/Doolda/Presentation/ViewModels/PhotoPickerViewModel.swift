//
//  PhotoPickerViewModel.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/08.
//

import Combine
import CoreImage
import Foundation

protocol PhotoPickerViewModelInput {
    func nextButtonDidTap(_ photoFrame: PhotoFrameType)
    func photoDidSelected(_ photos: [CIImage])
    func completeButtonDidTap()
}

protocol PhotoPickerViewModelOutput {
    var isReadyToCompose: Published<Bool>.Publisher { get }
    var isCompleted: Published<URL?>.Publisher { get }
    var errorPublisher: Published<Error?>.Publisher { get }
}

typealias PhotoPickerViewModelProtocol = PhotoPickerViewModelInput & PhotoPickerViewModelOutput

class PhotoPickerViewModel: PhotoPickerViewModelProtocol {
    var isReadyToCompose: Published<Bool>.Publisher { self.$readyToComposeState }
    var isCompleted: Published<URL?>.Publisher { self.$completeState }
    var errorPublisher: Published<Error?>.Publisher { self.$error }
    
    private let imageUseCase: ImageUseCaseProtocol
    private let imageComposeUseCase: ImageComposeUseCaseProtocol
    
    private var cancellables = Set<AnyCancellable>()
    private var selectedPhotoFrame: PhotoFrameType?
    @Published private var selectedPhotos: [CIImage]?
    @Published private var readyToComposeState: Bool = false
    @Published private var completeState: URL?
    @Published private var error: Error?
    
    init(imageUseCase: ImageUseCaseProtocol, imageComposeUseCase: ImageComposeUseCaseProtocol) {
        self.imageUseCase = imageUseCase
        self.imageComposeUseCase = imageComposeUseCase
        bind()
    }
    
    func nextButtonDidTap(_ photoFrame: PhotoFrameType) {
        self.selectedPhotoFrame = photoFrame
    }
    
    func photoDidSelected(_ photos: [CIImage]) {
        self.selectedPhotos = photos
    }
    
    func completeButtonDidTap() {
        guard self.readyToComposeState,
              let selectedPhotoFrame = selectedPhotoFrame,
              let selectedPhotos = selectedPhotos else { return }
        
        self.imageComposeUseCase.compose(photoFrameType: selectedPhotoFrame, images: selectedPhotos)
            .sink { [weak self] completion in
                guard case .failure(let error) = completion else { return }
                self?.error = error
            } receiveValue: { [weak self] composedImage in
                guard let self = self else { return }
                self.imageUseCase.saveLocal(image: composedImage)
                    .sink(receiveValue: { localUrl in
                        self.completeState = localUrl
                    })
                    .store(in: &self.cancellables)
            }
            .store(in: &self.cancellables)
    }
    
    private func bind() {
        self.$selectedPhotos
            .sink { [weak self] images in
                guard let self = self,
                      let images = images,
                      let requiredPhotoCount = self.selectedPhotoFrame?.rawValue?.requiredPhotoCount else { return }
                
                self.readyToComposeState = images.count == requiredPhotoCount
            }
            .store(in: &self.cancellables)
    }
}
