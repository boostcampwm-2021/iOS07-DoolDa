//
//  StickerPickerViewModel.swift
//  Doolda
//
//  Created by 김민주 on 2021/11/15.
//

import CoreGraphics
import Foundation

protocol StickerPickerViewModelProtocol {
    func getStickerPacks() -> [StickerPackType]
    func getStickerPackEntity(at index: Int) -> StickerPackEntity?
    func getStickerUrl(at indexPath: IndexPath) -> URL?
    func stickerDidSelect(at indexPath: IndexPath) -> StickerComponentEntity?
}

class StickerPickerViewModel: StickerPickerViewModelProtocol {
    private let stickerUseCase: StickerUseCase
    
    init(stickerUseCase: StickerUseCase) {
        self.stickerUseCase = stickerUseCase
    }
    
    func getStickerPacks() -> [StickerPackType] {
        return stickerUseCase.stickerPacks
    }

    func getStickerPackEntity(at index: Int) -> StickerPackEntity? {
        return stickerUseCase.getStickerPackEntity(at: index)
    }

    func getStickerUrl(at indexPath: IndexPath) -> URL? {
        return stickerUseCase.getStickerUrl(at: indexPath)
    }

    func stickerDidSelect(at indexPath: IndexPath) -> StickerComponentEntity? {
        return self.stickerUseCase.selectSticker(at: indexPath)
    }
}
