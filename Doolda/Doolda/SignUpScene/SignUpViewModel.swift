//
//  SignUpViewModel.swift
//  Doolda
//
//  Created by minju kim on 2022/05/15.
//

import Combine
import Foundation

protocol SignUpViewModelInput {
    var emailInput: String { get set }
    var passwordInput: String { get set }
    var passwordConfirmInput: String { get set }
}

protocol SignUpViewModelOutput {
    var isEmailValidPublisher: PassthroughSubject<Bool, Never> { get }
}

typealias SignUpViewModelProtocol = SignUpViewModelInput & SignUpViewModelOutput

final class SignUpViewModel: SignUpViewModelProtocol {

    @Published var emailInput: String = ""
    @Published var passwordInput: String = ""
    @Published var passwordConfirmInput: String = ""

    var isEmailValidPublisher = PassthroughSubject<Bool, Never>()


    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        bind()
    }

    private func bind() {
        self.$emailInput.sink { [weak self] email in
            guard let self = self else { return }
            self.isEmailValidPublisher.send(self.checkEamilVaild(email))
        }
        .store(in: &self.cancellables)

    }

    private func checkEamilVaild(_ email: String) -> Bool {
        return NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}").evaluate(with: email)
    }


}
