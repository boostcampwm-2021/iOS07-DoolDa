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
    
    func stickerDidSelect(at indexPath: IndexPath) -> StickerComponentEntity? {
        return self.stickerUseCase.selectSticker(at: indexPath)
    }
}
