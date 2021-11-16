//
//  StickerUseCase.swift
//  Doolda
//
//  Created by 김민주 on 2021/11/16.
//

import CoreGraphics
import Foundation

protocol StickerUseCaseProtocol {
    var stickerPacks: [StickerPackType] { get }
    func selectSticker(at indexPath: IndexPath) -> StickerComponentEntity?
}

class StickerUseCase: StickerUseCaseProtocol {
    let stickerPacks: [StickerPackType]
    
    init() {
        self.stickerPacks = StickerPackType.allCases
    }
    
    func selectSticker(at indexPath: IndexPath) -> StickerComponentEntity? {
        guard let selectedStickerPack = self.stickerPacks[indexPath.section].rawValue else { return nil }
        
        let stickerComponentEntity = StickerComponentEntity(
            frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 300, height: 300)),
            scale: 1.0,
            angle: 0,
            aspectRatio: 1,
            stickerUrl: selectedStickerPack.stickersUrl[indexPath.item]
        )
        return stickerComponentEntity
    }
}
