//
//  SettingsTableViewHeader.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/22.
//

import Combine
import UIKit

import SnapKit

class SettingsTableViewHeader: UITableViewHeaderFooterView {

    // MARK: - Static Properties

    static let identifier = "SettingsTableViewHeader"

    // MARK: - Subviews

    private lazy var titleLabel: UILabel = {
        let title = UILabel()
        title.font = .systemFont(ofSize: 16)
        title.textColor = .dooldaSubLabel
        return title
    }()

    // MARK: - Public Properties

    @Published var title: String?
    @Published var font: UIFont?

    // MARK: - Private Properties

    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Initializers

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.configureUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureUI()
    }

    // MARK: - Helpers

    private func configureUI() {
        self.addSubview(titleLabel)
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-16)
            make.leading.equalToSuperview().offset(16)
            make.width.equalToSuperview()
        }
    }

    private func configureFont() {
        self.titleLabel.font = self.font
    }

    private func bindUI() {
        self.$title
            .receive(on: DispatchQueue.main)
            .sink { [weak self] title in
                self?.titleLabel.text = title
            }
            .store(in: &self.cancellables)

        self.$font
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.configureFont()
            }
            .store(in: &self.cancellables)
    }

}
