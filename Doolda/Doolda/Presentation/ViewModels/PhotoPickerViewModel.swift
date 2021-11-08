//
//  PhotoPickerViewModel.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/08.
//

import Combine
import Foundation

protocol PhotoPickerViewModelInput {
    func nextButtonDidTap(_ photoFrame: PhotoFrameEntity)
    func photoDidSelected(_ photos: [URL])
    func completeButtonDidTap()
    func cancelButtonDidTap()
}

protocol PhotoPickerViewModelOutput {
    var isReadyToCompose: Published<Bool>.Publisher { get }
    var isCompleted: Published<URL?>.Publisher { get }
    var errorPublisher: Published<Error?>.Publisher { get }
}

typealias PhotoPickerViewModelProtocol = PhotoPickerViewModelInput & PhotoPickerViewModelOutput
