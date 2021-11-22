//
//  SettingsTableViewCell.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/22.
//

import UIKit

import SnapKit

class SettingsTableViewCell: UITableViewCell {

    // MARK: - Static Properties

    static let identifier = "SettingsTableViewCell"

    // MARK: - Subviews

    private lazy var title: UILabel = {
        let label = UILabel()
        return label
    }()

    private lazy var rightItem: UIView = {
        let item = UIView()
        return item
    }()

    // MARK: - Initializers

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.configureUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureUI()
    }

    // MARK: - Helpers

    private func configureUI() {
        self.contentView.addSubview(self.title)
        self.title.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.6)
        }

        self.contentView.addSubview(self.rightItem)
        self.rightItem.snp.makeConstraints { make in
            make.top.trailing.bottom.equalToSuperview()
            make.leading.equalTo(self.title)
        }
    }

}
