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
        case detail, disclosure, switchControl
    }

    // MARK: - Static Properties

    static let identifier = "SettingsTableViewCell"

    // MARK: - Subviews

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        return stackView
    }()

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

    lazy var switchControl: UISwitch = {
        let switchControl = UISwitch()
        switchControl.onTintColor = .dooldaHighlighted
        return switchControl
    }()

    private lazy var separator: CALayer = {
        let separator = CALayer()
        separator.backgroundColor = UIColor.dooldaLabel?.withAlphaComponent(0.2).cgColor
        return separator
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
        self.configureFont()
        self.bindUI()
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: - LifeCycle Methods

    override func setNeedsLayout() {
        super.setNeedsLayout()
        separator.frame = CGRect(x: 16, y: self.frame.height - 1, width: self.frame.width-32, height: 1)
    }

    // MARK: - Helpers

    private func configureUI() {
        self.backgroundColor = .clear

        self.stackView.addArrangedSubview(self.titleLabel)
        self.stackView.addArrangedSubview(self.detailLabel)
        self.stackView.addArrangedSubview(self.switchControl)
        self.contentView.addSubview(self.stackView)

        self.stackView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }

        self.layer.addSublayer(self.separator)

        switch self.style {
        case .disclosure:
            self.accessoryType = .disclosureIndicator
            self.detailLabel.isHidden = true
            self.switchControl.isHidden = true
        case .detail:
            self.detailLabel.isHidden = false
            self.switchControl.isHidden = true
        case .switchControl:
            self.detailLabel.isHidden = true
            self.switchControl.isHidden = false
        default: return
        }
    }

    private func configureFont() {
        var font = self.font
        if font == nil { font = .systemFont(ofSize: 16) }

        self.titleLabel.font = font
        self.detailLabel.font = font
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
                self?.detailLabel.snp.updateConstraints { make in
                    make.width.equalTo(self?.detailLabel.intrinsicContentSize.width ?? 0)
                }
            }
            .store(in: &self.cancellables)
    }
    
}
