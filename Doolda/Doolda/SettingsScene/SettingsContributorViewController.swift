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

    // MARK: - LifeCycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
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
}
