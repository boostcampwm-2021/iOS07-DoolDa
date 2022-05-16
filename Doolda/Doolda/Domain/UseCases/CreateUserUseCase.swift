//
//  CreateUserUseCase.swift
//  Doolda
//
//  Created by Seunghun Yang on 2022/05/16.
//

import Combine
import Foundation

final class CreateUserUseCase: CreateUserUseCaseProtocol {
    // TODO: [Dozzing] 여기 + UsrRepository (uid 를 DDID로 매핑해주는것도 신경쓰셔야합니다)
    // 이름이 DDID 내용이 User, uid를 이름으로하고 DDID값을 가지는 추가 컬렉션을 만들어서 중간에 매핑하게하자. <- 중간에 매핑하는거는 승지가 한다. 
    func create(uid: String) -> AnyPublisher<User, Error> {
        Fail(error: AuthenticatoinError.missingAuthDataResult).eraseToAnyPublisher()
    }
}
