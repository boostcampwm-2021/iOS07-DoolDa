//
//  GetRawPageUseCase.swift
//  Doolda
//
//  Created by 정지승 on 2021/11/18.
//

import Combine
import Foundation
import FirebaseStorage

final class GetRawPageUseCase: GetRawPageUseCaseProtocol {
    private let rawPageRepository: RawPageRepositoryProtocol
    private let pageRepository: PageRepositoryProtocol
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(rawPageRepository: RawPageRepositoryProtocol, pageRepository: PageRepositoryProtocol) {
        self.rawPageRepository = rawPageRepository
        self.pageRepository = pageRepository
    }
    
    func getRawPageEntity(metaData: PageEntity) -> AnyPublisher<RawPageEntity, Error> {
        return self.rawPageRepository.fetch(metaData: metaData)
            .catch { [weak self] error -> AnyPublisher<RawPageEntity, Error> in
                let storageError = StorageErrorCode(rawValue: (error as NSError).code)
                if storageError == .objectNotFound { self?.deleteDummyPage(for: metaData) }
                return Fail(error: error).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    private func deleteDummyPage(for page: PageEntity) {
        self.pageRepository.deletePage(for: page)
            .sink (receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &self.cancellables)
    }
}
