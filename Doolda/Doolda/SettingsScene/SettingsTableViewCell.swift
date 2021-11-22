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
        label.font = .systemFont(ofSize: 16)
        label.textColor = .dooldaLabel
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
        self.backgroundColor = .clear

        self.contentView.addSubview(self.title)
        self.title.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.bottom.equalToSuperview().offset(-12)
            make.leading.equalToSuperview().offset(16)
            make.width.equalToSuperview().multipliedBy(0.6)
        }

        self.contentView.addSubview(self.rightItem)
        self.rightItem.snp.makeConstraints { make in
            make.top.bottom.equalTo(self.title)
            make.trailing.equalToSuperview().offset(-16)
            make.leading.equalTo(self.title.snp.trailing)
        }
    }

    // MARK: - Public Methods

    func configure(title: String, rightItem: UIView) {
        self.title.text = title
        self.rightItem = rightItem
    }

}
