//
//  DiaryPageViewModel.swift
//  Doolda
//
//  Created by Seunghun Yang on 2021/11/17.
//

import Foundation

protocol DiaryPageViewModelInput {
    
}

protocol DiaryPageViewModelOutput {
    var componentsPublisher: Published<[ComponentEntity]>.Publisher { get }
    var backgroundPublisher: Published<BackgroundType>.Publisher { get }
}

typealias DiaryPageViewModelProtocol = DiaryPageViewModelInput & DiaryPageViewModelOutput
