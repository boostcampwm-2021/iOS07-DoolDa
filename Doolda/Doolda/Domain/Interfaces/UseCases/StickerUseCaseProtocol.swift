//
//  StickerUseCaseProtocol.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/29.
//

import CoreGraphics
import Foundation

protocol StickerUseCaseProtocol {
    var stickerPacks: [StickerPackType] { get }
    func getStickerPackEntity(at index: Int) -> StickerPackEntity?
    func getStickerName(at indexPath: IndexPath) -> String?
    func selectSticker(at indexPath: IndexPath) -> StickerComponentEntity?
}
