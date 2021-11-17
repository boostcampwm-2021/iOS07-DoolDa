//
//  DiaryPageViewModel.swift
//  Doolda
//
//  Created by Seunghun Yang on 2021/11/17.
//

import Combine
import CoreGraphics
import Foundation

//protocol DiaryPageViewModelInput {
//
//}
//
//protocol DiaryPageViewModelOutput {
//    var rawPagePublisher: Published<RawPageEntity?>.Publisher { get }
//}
//
//typealias DiaryPageViewModelProtocol = DiaryPageViewModelInput & DiaryPageViewModelOutput
//
//class DiaryPageViewModel: DiaryPageViewModelProtocol {
//    var rawPagePublisher: Published<RawPageEntity?>.Publisher { self.$rawPage }
//
//    private let user: User
//    private let pageEntity: PageEntity
//    private let displayPageUseCase: DisplayPageUseCaseProtocol
//
//    @Published private var rawPage: RawPageEntity?
//
//    init(user: User, pageEntity: PageEntity, displayPageUseCase: DisplayPageUseCaseProtocol) {
//        self.user = user
//        self.pageEntity = pageEntity
//        self.displayPageUseCase = displayPageUseCase
//        displayPageUseCase.getRawPageEntity(for: user.pairI, jsonPath: <#T##String#>)
//    }
//}
//
//
protocol DisplayPageUseCaseProtocol {
    func getRawPageEntity(for pairId: DDID, jsonPath: String) -> AnyPublisher<RawPageEntity, Error>
}

class DisplayPageUseCase: DisplayPageUseCaseProtocol {
    let repository = RawPageRepository(networkService: URLSessionNetworkService())
    
    func getRawPageEntity(for pairId: DDID, jsonPath: String) -> AnyPublisher<RawPageEntity, Error> {
        return repository.fetch(at: pairId.ddidString, with: "211117175856")
    }
}
