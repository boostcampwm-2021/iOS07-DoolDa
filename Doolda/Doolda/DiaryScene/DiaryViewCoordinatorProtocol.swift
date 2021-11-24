//
//  DiaryViewCoordinatorProtocol.swift
//  Doolda
//
//  Created by Seunghun Yang on 2021/11/08.
//

import Foundation

protocol DiaryViewCoordinatorProtocol: CoordinatorProtocol {
    func editPageRequested()
    func settingsPageRequested()
    func filteringSheetRequested(authorFilter: DiaryAuthorFilter, orderFilter: DiaryOrderFilter)
    func pageDetailRequested(pageEntity: PageEntity)
}
