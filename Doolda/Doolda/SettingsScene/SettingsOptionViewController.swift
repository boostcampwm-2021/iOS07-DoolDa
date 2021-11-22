//
//  SettingsOptionViewController.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/22.
//

import Combine
import UIKit

import SnapKit

class SettingsOptionViewController: UIViewController {

    // MARK: - Subviews

    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.setImage(.left, for: .normal)
        return button
    }()

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()

    private var contentView: UIView = UIView()

    // MARK: - Private Properties

    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Initializers

    convenience init(title: String, content: UIView) {
        self.init(nibName: nil, bundle: nil)
        self.navigationItem.title = title
        self.contentView = contentView
        self.configureUI()
        self.bindUI()
    }

    // MARK: - Helpers

    private func configureUI() {
        self.view.backgroundColor = .dooldaBackground
        self.navigationController?.navigationBar.barTintColor = .dooldaLabel
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: self.backButton)

        self.view.addSubview(self.scrollView)
        self.scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.scrollView.addSubview(self.contentView)
        self.contentView.snp.makeConstraints { make in
            make.top.bottom.equalTo(self.scrollView.frameLayoutGuide)
            make.leading.equalTo(self.scrollView.frameLayoutGuide).offset(16)
            make.trailing.equalTo(self.scrollView.frameLayoutGuide).offset(-16)
        }
    }

    private func bindUI() {
        self.backButton.publisher(for: .touchUpInside)
            .sink { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }
            .store(in: &self.cancellables)
    }

}
