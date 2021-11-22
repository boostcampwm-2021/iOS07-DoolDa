//
//  SettingsViewController.swift
//  Doolda
//
//  Created by Dozzing on 2021/11/21.
//

import Combine
import UIKit

import SnapKit

class SettingsViewController: UIViewController {

    struct SettingsSection {
        let title: String
        var settingsOptions: [SettingsOptions]
    }

    struct SettingsOptions {
        let cell: UITableViewCell
        let handler: (() -> Void)?
    }

    // MARK: - Subviews

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(SettingsTableViewCell.self, forCellReuseIdentifier: SettingsTableViewCell.identifier)
        tableView.register(SettingsTableViewHeader.self, forHeaderFooterViewReuseIdentifier: SettingsTableViewHeader.identifier)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()

    // MARK: - Private Properties

    private var viewModel: SettingsViewModelProtocol!
    private var cancellables: Set<AnyCancellable> = []

    private lazy var settingsSections: [SettingsSection] = {
        let alertOption = SettingsOptions(
            cell: SettingsTableViewCell(title: "푸시 알림 허용", rightItem: UILabel()),
            handler: nil
        )

        let fontOption = SettingsOptions(
            cell: SettingsTableViewCell(title: "폰트 설정", rightItem: UILabel()),
            handler: nil
        )

        let appVersionLabel = UILabel()
        appVersionLabel.text = DooldaInfoType.appVersion.rawValue
        appVersionLabel.textColor = .dooldaLabel
        let appVersionOption = SettingsOptions(
            cell: SettingsTableViewCell(title: "앱 현재 버전", rightItem: appVersionLabel),
            handler: nil
        )

        let openSourceItem = UIImageView(image: .right)
        openSourceItem.tintColor = .dooldaLabel
        let openSourceOption = SettingsOptions(
            cell: SettingsTableViewCell(title: "Open Source License", rightItem: openSourceItem),
            handler: self.viewModel.openSourceLicenseDidTap
        )

        let privacyItem = UIImageView(image: .right)
        privacyItem.tintColor = .dooldaLabel
        let privacyOption = SettingsOptions(
            cell: SettingsTableViewCell(title: "개인 정보 처리 방침", rightItem: privacyItem),
            handler: self.viewModel.privacyPolicyDidTap
        )

        let contributorItem = UIImageView(image: .right)
        contributorItem.tintColor = .dooldaLabel
        let contributorsOption = SettingsOptions(
            cell: SettingsTableViewCell(title: "만든 사람들", rightItem: contributorItem),
            handler: self.viewModel.contributorDidTap
        )

        let appSection = SettingsSection(title: "앱 설정", settingsOptions: [alertOption, fontOption])
        let serviceSection = SettingsSection(
            title: "서비스 정보",
            settingsOptions: [appVersionOption, openSourceOption, privacyOption, contributorsOption]
        )

        let sections: [SettingsSection] = [appSection, serviceSection]
        return sections
    }()

    // MARK: - Initializers

    convenience init(viewModel: SettingsViewModelProtocol) {
        self.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }

    // MARK: - LifeCycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
    }

    // MARK: - Helpers

    private func configureUI() {
        self.view.backgroundColor = .dooldaBackground
        self.title = "설정"

        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.tintColor = .dooldaLabel
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationItem.backButtonTitle = ""

        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

}

extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = self.settingsSections[exist: indexPath.section],
              let handler = section.settingsOptions[exist: indexPath.row]?.handler else { return }
        handler()
    }
}

extension SettingsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.settingsSections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.settingsSections[exist: section]?.settingsOptions.count ?? 0
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(
                withIdentifier: SettingsTableViewHeader.identifier
              ) as? SettingsTableViewHeader else { return nil }

        header.configure(with: self.settingsSections[section].title)
        return header
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = self.settingsSections[exist: indexPath.section],
              let cell = section.settingsOptions[exist: indexPath.row]?.cell else { return UITableViewCell() }

        let separator = CALayer()
        separator.frame = CGRect(x: 16, y: cell.frame.height - 1, width: self.tableView.frame.width-32, height: 1)
        separator.backgroundColor = UIColor.dooldaLabel?.withAlphaComponent(0.2).cgColor
        cell.layer.addSublayer(separator)
        cell.selectionStyle = .none
        return cell
    }
}
