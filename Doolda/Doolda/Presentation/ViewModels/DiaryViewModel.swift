//
//  DiaryViewModel.swift
//  Doolda
//
//  Created by Seunghun Yang on 2021/11/16.
//

import Foundation

protocol DiaryViewModelInput {
    func filterButtonDidTap()
    func displayModeToggleButtonDidTap()
    func addPageButtonDidTap()
    func lastPageDidDisplay()
    func filterDidApply(author: DiaryAuthorFilter, orderBy: DiaryOrderFilter)
}

protocol DiaryViewModelOutput {
    var displayModePublisher: Published<DiaryDisplayMode>.Publisher { get }
    var isMyTurnPublisher: Published<Bool>.Publisher { get }
    var filteredPageEntitiesPublisher: Published<[PageEntity]>.Publisher { get }
    var displayMode: DiaryDisplayMode { get }
}

typealias DiaryViewModelProtocol = DiaryViewModelInput & DiaryViewModelOutput

enum DiaryDisplayMode {
    case carousel, list
}

enum DiaryAuthorFilter {
    case user, friend, both
}

enum DiaryOrderFilter {
    case ascending, descending
}
