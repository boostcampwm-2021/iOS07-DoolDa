//
//  GetMyIdUsecasePorotocol.swift
//  Doolda
//
//  Created by 김민주 on 2021/11/02.
//

import Foundation
import Combine

protocol GetMyIdUsecaseProtocol {
    func getMyId() -> AnyPublisher<String, Error>
    
}
