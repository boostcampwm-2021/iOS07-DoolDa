//
//  LoginRepository.swift
//  Doolda
//
//  Created by user on 2022/06/16.
//

import Combine
import Foundation
import UIKit

enum LoginRepositoryError: LocalizedError {
    case nilDeviceId

    var errorDescription: String? {
        switch self {
        case .nilDeviceId:
            return "device id가 존재하지 않습니다."
        }
    }
}

final class LoginRepository: LoginRepositoryProtocol {
    private let userDefaultsPersistenceService: UserDefaultsPersistenceServiceProtocol
    private let firebaseNetworkService: FirebaseNetworkServiceProtocol

    private var cancellables = Set<AnyCancellable>()

    init(persistenceService: UserDefaultsPersistenceServiceProtocol, networkService: FirebaseNetworkServiceProtocol) {
        self.userDefaultsPersistenceService = persistenceService
        self.firebaseNetworkService = networkService
    }

    func setCurrentDevice(for user: User) -> AnyPublisher<Void, Error> {
        guard let deviceId = UIDevice.current.identifierForVendor?.uuidString else {
            return Fail(error: LoginRepositoryError.nilDeviceId).eraseToAnyPublisher()
        }

        return self.firebaseNetworkService.setDocument(collection: .login,
                                                       document: user.id.ddidString,
                                                       dictionary: ["currentDevice": deviceId])
    }

    func observeLogin(for user: User) -> AnyPublisher<String, Error> {
        let publisher = self.firebaseNetworkService
            .observeDocument(collection: .login, document: user.id.ddidString)

        return publisher
            .compactMap{ data in
                return data["currentDevice"] as? String
            }
            .eraseToAnyPublisher()
    }
}
