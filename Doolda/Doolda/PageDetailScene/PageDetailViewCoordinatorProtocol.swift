//
//  PageDetailViewCoordinatorProtocol.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/24.
//

import Foundation

protocol PageDetailViewCoordinatorProtocol: CoordinatorProtocol {
    func editPageRequested(with rawPageEntity: RawPageEntity)
}
