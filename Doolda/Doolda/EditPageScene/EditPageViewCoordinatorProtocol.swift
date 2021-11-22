//
//  EditPageViewCoordinatorProtocol.swift
//  Doolda
//
//  Created by 김민주 on 2021/11/08.
//

import Foundation

protocol EditPageViewCoordinatorProtocol: CoordinatorProtocol {
    func editingPageSaved()
    func editingPageCanceled()
    func addPhotoComponent()
    func editTextComponent(with textComponent: TextComponentEntity?)
    func addStickerComponent()
    func changeBackgroundType()
}
