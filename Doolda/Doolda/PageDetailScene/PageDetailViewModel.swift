//
//  PageDetailViewModel.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/24.
//

import Combine
import Foundation

protocol PageDetailViewModelInput {
    func editPageButtonDidTap()
    func backButtonDidTap()
}

protocol PageDetailViewModelOuput {
    var rawPageEntityPublisher: Published<RawPageEntity?>.Publisher { get }
    var errorPublisher: Published<Error?>.Publisher { get }
}

typealias PageDetailViewModelProtocol = PageDetailViewModelInput & PageDetailViewModelOuput
