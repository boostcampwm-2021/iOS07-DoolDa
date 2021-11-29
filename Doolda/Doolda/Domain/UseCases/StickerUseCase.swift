//
//  StickerUseCase.swift
//  Doolda
//
//  Created by 김민주 on 2021/11/16.
//

import CoreGraphics
import Foundation

final class StickerUseCase: StickerUseCaseProtocol {
    let stickerPacks: [StickerPackType]
    
    init() {
        self.stickerPacks = StickerPackType.allCases
    }

    func getStickerPackEntity(at index: Int) -> StickerPackEntity? {
        if StickerPackType.allCases.count <= index { return nil }
        return StickerPackType.allCases[index].rawValue
    }

    func getStickerName(at indexPath: IndexPath) -> String? {
        guard let stickerPack = self.getStickerPackEntity(at: indexPath.section) else { return nil }
        if stickerPack.stickerCount <= indexPath.item { return nil }
        return stickerPack.stickersName[indexPath.item]
    }
    
    func selectSticker(at indexPath: IndexPath) -> StickerComponentEntity? {
        guard let selectedStickerPack = self.stickerPacks[indexPath.section].rawValue else { return nil }
        
        let stickerComponentEntity = StickerComponentEntity(
            frame: CGRect(origin: CGPoint(x: 700, y: 1350), size: CGSize(width: 300, height: 300)),
            scale: 1.0,
            angle: 0,
            aspectRatio: 1,
            name: selectedStickerPack.stickersName[indexPath.item]
        )
        return stickerComponentEntity
    }
}
