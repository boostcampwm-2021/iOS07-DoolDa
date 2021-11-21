//
//  StickerPickerViewModel.swift
//  Doolda
//
//  Created by 김민주 on 2021/11/15.
//

import CoreGraphics
import Foundation

protocol StickerPickerBottomSheetViewModelProtocol {
    func getStickerPacks() -> [StickerPackType]
    func getStickerPackEntity(at index: Int) -> StickerPackEntity?
    func getStickerName(at indexPath: IndexPath) -> String?
    func stickerDidSelect(at indexPath: IndexPath) -> StickerComponentEntity?
}

class StickerPickerBottomSheetViewModel: StickerPickerBottomSheetViewModelProtocol {
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

    func getStickerName(at indexPath: IndexPath) -> String? {
        return stickerUseCase.getStickerName(at: indexPath)
    }

    func stickerDidSelect(at indexPath: IndexPath) -> StickerComponentEntity? {
        return self.stickerUseCase.selectSticker(at: indexPath)
    }
}
