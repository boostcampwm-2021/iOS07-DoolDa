//
//  SettingsTableViewCell.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/22.
//

import Combine
import UIKit

import SnapKit

class SettingsTableViewCell: UITableViewCell {

    enum Style {
        case detail, disclosure, switchButton
    }

    // MARK: - Static Properties

    static let identifier = "SettingsTableViewCell"

    // MARK: - Subviews

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .dooldaLabel
        label.text = "title"
        return label
    }()

    private lazy var detailLabel: UILabel = {
        let label = UILabel()
        label.textColor = .dooldaLabel
        return label

    }()

    // MARK: - Public Properties

    @Published var title: String?
    @Published var detailText: String?
    @Published var font: UIFont?

    // MARK: - Private Properties

    private var style: Style?
    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Initializers

    convenience init(style: Style) {
        self.init()
        self.style = style
        self.configureUI()
        self.bindUI()
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: - Helpers

    private func configureUI() {
        self.backgroundColor = .clear

        self.contentView.addSubview(self.detailLabel)
        self.detailLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.bottom.equalToSuperview().offset(-12)
            make.trailing.equalToSuperview().offset(-16)
            make.width.equalTo(self.detailLabel.intrinsicContentSize.width)
        }

        self.contentView.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.bottom.equalToSuperview().offset(-12)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalTo(self.detailLabel.snp.leading)
        }

        switch self.style {
        case .disclosure:
            self.accessoryType = .disclosureIndicator
            self.detailLabel.isHidden = true
        case .detail:
            self.detailLabel.isHidden = false
        default: return
        }
    }

    private func configureFont() {
        self.titleLabel.font = self.font
        self.detailLabel.font = self.font
    }

    private func bindUI() {
        self.$title
            .receive(on: DispatchQueue.main)
            .sink { [weak self] title in
                self?.titleLabel.text = title
            }
            .store(in: &self.cancellables)

        self.$detailText
            .receive(on: DispatchQueue.main)
            .sink { [weak self] detailText in
                self?.detailLabel.text = detailText
                self?.detailLabel.snp.updateConstraints { make in
                    make.width.equalTo(self?.detailLabel.intrinsicContentSize.width ?? 0)
                }
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
