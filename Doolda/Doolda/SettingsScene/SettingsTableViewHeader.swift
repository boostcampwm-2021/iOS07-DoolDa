//
//  SettingsTableViewHeader.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/22.
//

import UIKit

import SnapKit

class SettingsTableViewHeader: UITableViewHeaderFooterView {

    // MARK: - Static Properties

    static let identifier = "SettingsTableViewHeader"

    // MARK: - Subviews

    lazy var title: UILabel = {
        let title = UILabel()
        title.font = .systemFont(ofSize: 16)
        title.textColor = .dooldaSubLabel
        return title
    }()

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
        self.addSubview(title)
        self.title.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-16)
            make.width.equalToSuperview()
        }
    }

    // MARK: - Public Methods

    func configure(with title: String) {
        self.title.text = title
    }

}
