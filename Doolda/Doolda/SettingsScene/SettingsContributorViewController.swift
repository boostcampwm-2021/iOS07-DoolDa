//
//  SettingsContributorViewController.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/29.
//

import Combine
import UIKit

import SnapKit

class SettingsContributorViewController: UIViewController {

    // MARK: - Subviews

    private var imageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()

    // MARK: - Public Properties

    @Published var titleText: String?
    
    // MARK: - Private Properties

    private var cancellables: Set<AnyCancellable> = []

    // MARK: - LifeCycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
        self.bindUI()
    }

    // MARK: - Helpers

    private func configureUI() {
        self.view.backgroundColor = .dooldaBackground

        self.view.addSubview(self.imageView)
        self.imageView.snp.makeConstraints { make in
            make.top.leading.equalTo(self.view.safeAreaLayoutGuide).offset(16)
            make.bottom.trailing.equalTo(self.view.safeAreaLayoutGuide).offset(-16)
        }
    }

    private func bindUI() {
        self.$titleText
            .receive(on: DispatchQueue.main)
            .sink { [weak self] title in
                self?.navigationItem.title = title
            }
            .store(in: &self.cancellables)
    }
}
