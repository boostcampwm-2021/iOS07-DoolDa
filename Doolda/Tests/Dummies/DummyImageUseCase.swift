//
//  DummyImageUseCase.swift
//  EditPageUseCaseTest
//
//  Created by 김민주 on 2021/11/30.
//

import Combine
import CoreImage
import Foundation

class DummyImageUseCase: ImageUseCaseProtocol {
    var isSuccessMode: Bool = true
    
    init(isSuccessMode: Bool) {
        self.isSuccessMode = isSuccessMode
    }
    
    func saveLocal(image: CIImage) -> AnyPublisher<URL, Error> {
        if isSuccessMode {
            return Just(URL(string: "https://naver.com")!).setFailureType(to: Error.self).eraseToAnyPublisher()
        } else {
            return Fail(error: DummyError.failed).eraseToAnyPublisher()
        }
    }
    
    func saveRemote(for user: User, localUrl: URL) -> AnyPublisher<URL, Error> {
        if isSuccessMode {
            return Just(URL(string: "https://youtube.com")!).setFailureType(to: Error.self)
                .delay(for: .seconds(1), tolerance: nil, scheduler: RunLoop.main, options: nil)
                .eraseToAnyPublisher()
        } else {
            return Fail(error: DummyError.failed).eraseToAnyPublisher()
        }
    }
}
