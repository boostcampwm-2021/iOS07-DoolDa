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

    private var contentView: UILabel = {
        let label = UILabel()
        label.textColor = .dooldaLabel
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .left
        return label
    }()

    // MARK: - Private Properties

    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Initializers

    convenience init(title: String, content: String) {
        self.init(nibName: nil, bundle: nil)
        self.navigationItem.title = title
        self.contentView.text = content
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
            make.edges.equalTo(self.view.safeAreaLayoutGuide).offset(16)
        }

        self.scrollView.addSubview(self.contentView)
        self.contentView.snp.makeConstraints { make in
            make.top.equalTo(self.scrollView.frameLayoutGuide)
            make.leading.equalTo(self.scrollView.frameLayoutGuide)
            make.trailing.equalTo(self.scrollView.frameLayoutGuide)
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
