//
//  FilterOptionBottomSheetViewModel.swift
//  Doolda
//
//  Created by Seunghun Yang on 2021/11/21.
//

import Foundation

protocol FilterOptionBottomSheetViewModelInput {
    func authorFilterIndexValueDidChange(_ index: Int)
    func orderFilterIndexValueDidChange(_ index: Int)
}

protocol FilterOptionBottomSheetViewModelOutput {
    var authorFilterPublisher: Published<DiaryAuthorFilter>.Publisher { get }
    var orderFilterPublisher: Published<DiaryOrderFilter>.Publisher { get }
}

typealias FilterOptionBottomSheetViewModelProtocol = FilterOptionBottomSheetViewModelInput & FilterOptionBottomSheetViewModelOutput

class FilterOptionBottomSheetViewModel: FilterOptionBottomSheetViewModelInput, FilterOptionBottomSheetViewModelOutput {
    var authorFilterPublisher: Published<DiaryAuthorFilter>.Publisher { self.$authorFilter }
    var orderFilterPublisher: Published<DiaryOrderFilter>.Publisher { self.$orderFilter }
    
    @Published private var authorFilter: DiaryAuthorFilter = .both
    @Published private var orderFilter: DiaryOrderFilter = .descending
    
    init(authorFilter: DiaryAuthorFilter, orderFilter: DiaryOrderFilter) {
        self.authorFilter = authorFilter
        self.orderFilter = orderFilter
    }
    
    func authorFilterIndexValueDidChange(_ index: Int) {
        self.authorFilter = DiaryAuthorFilter[index] ?? .both
    }
    
    func orderFilterIndexValueDidChange(_ index: Int) {
        self.orderFilter = DiaryOrderFilter[index] ?? .descending
    }
}
