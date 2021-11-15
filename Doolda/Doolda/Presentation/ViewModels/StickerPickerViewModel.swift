//
//  StickerPickerViewModel.swift
//  Doolda
//
//  Created by 김민주 on 2021/11/15.
//

import CoreGraphics
import Foundation

protocol StickerPickerViewModelProtocol {
    var stickerPack: [StickerPackType] { get }
    func stickerDidSelect(at indexPath: IndexPath) -> StickerComponentEntity?
}


class StickerPickerViewModel: StickerPickerViewModelProtocol {
    let stickerPack: [StickerPackType]
    
    init() {
        self.stickerPack = StickerPackType.allCases
    }
    
    func stickerDidSelect(at indexPath: IndexPath) -> StickerComponentEntity? {
        guard let selectedStickerPack = self.stickerPack[indexPath.section].rawValue else { return nil }
        let stickerComponentEntity = StickerComponentEntity(
            frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 100, height: 100)),
            scale: 1.0,
            angle: 0,
            aspectRatio: 1,
            stickerUrl: selectedStickerPack.stickersUrl[indexPath.item]
        )
        return stickerComponentEntity
    }
}
