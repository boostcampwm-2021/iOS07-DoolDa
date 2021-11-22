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

    private var rightItem: UIView = UIView()

    // MARK: - Initializers

    convenience init(title: String, rightItem: UIView) {
        self.init()
        self.title.text = title
        self.rightItem = rightItem
        self.configureUI()
    }

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

        self.contentView.addSubview(self.rightItem)
        self.rightItem.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.bottom.equalToSuperview().offset(-12)
            make.trailing.equalToSuperview().offset(-16)
            make.width.equalTo(self.rightItem.intrinsicContentSize.width)
        }

        self.contentView.addSubview(self.title)
        self.title.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.bottom.equalToSuperview().offset(-12)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalTo(self.rightItem.snp.leading)
        }
    }

    // MARK: - Public Methods

    func configure(title: String, rightItem: UIView) {
        self.title.text = title
        self.rightItem = rightItem
    }

}
