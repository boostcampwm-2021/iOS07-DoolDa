//
//  currentDeviceUseCase.swift
//  Doolda
//
//  Created by user on 2022/06/17.
//

import Combine
import UIKit

final class DeviceUseCase {
    private let loginRepository: LoginRepository

    init() {
        self.loginRepository = LoginRepository(persistenceService: UserDefaultsPersistenceService.shared,
                                               networkService: FirebaseNetworkService.shared)
    }

    func setCurrentDevice(for user: User) -> AnyPublisher<Void, Error> {
        return self.loginRepository.setCurrentDevice(for: user)
    }

    func checkIdIsCurrentDevice(with id: String) -> Bool {
        guard let deviceId = UIDevice.current.identifierForVendor?.uuidString else {
            return false
        }
        
        return id == deviceId
    }
}
