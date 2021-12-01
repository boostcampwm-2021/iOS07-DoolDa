//
//  FilterOptionBottomSheetViewModel.swift
//  Doolda
//
//  Created by Seunghun Yang on 2021/11/21.
//

import Combine
import Foundation

protocol FilterOptionBottomSheetViewModelInput {
    func authorFilterIndexValueDidChange(_ index: Int)
    func orderFilterIndexValueDidChange(_ index: Int)
}

protocol FilterOptionBottomSheetViewModelOutput {
    var authorFilterPublisher: AnyPublisher<DiaryAuthorFilter, Never> { get }
    var orderFilterPublisher: AnyPublisher<DiaryOrderFilter, Never> { get }
}

typealias FilterOptionBottomSheetViewModelProtocol = FilterOptionBottomSheetViewModelInput & FilterOptionBottomSheetViewModelOutput

class FilterOptionBottomSheetViewModel: FilterOptionBottomSheetViewModelInput, FilterOptionBottomSheetViewModelOutput {
    var authorFilterPublisher: AnyPublisher<DiaryAuthorFilter, Never> { self.$authorFilter.eraseToAnyPublisher() }
    var orderFilterPublisher: AnyPublisher<DiaryOrderFilter, Never> { self.$orderFilter.eraseToAnyPublisher() }
    
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
