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
        let cell: SettingsTableViewCell
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

    private lazy var settingsSections: [SettingsSection] = {
        let alertCell = SettingsTableViewCell(style: .switchControl)
        alertCell.title = "푸시 알림 허용"
        let alertOption = SettingsOptions(cell: alertCell, handler: nil)

        let fontCell = SettingsTableViewCell(style: .detail)
        fontCell.title = "폰트 설정"
        let fontOption = SettingsOptions(cell: fontCell, handler: nil)

        let versionCell = SettingsTableViewCell(style: .detail)
        versionCell.title = "앱 현재 버전"
        versionCell.detailText = DooldaInfoType.appVersion.rawValue
        let appVersionOption = SettingsOptions(cell: versionCell, handler: nil)

        let openSourceCell = SettingsTableViewCell(style: .disclosure)
        openSourceCell.title = "Open Source License"
        let openSourceOption = SettingsOptions(cell: openSourceCell, handler: self.viewModel.openSourceLicenseDidTap)

        let privacyCell = SettingsTableViewCell(style: .disclosure)
        privacyCell.title = "개인 정보 처리 방침"
        let privacyOption = SettingsOptions(cell: privacyCell, handler: self.viewModel.privacyPolicyDidTap)

        let contributorCell = SettingsTableViewCell(style: .disclosure)
        contributorCell.title = "만든 사람들"
        let contributorsOption = SettingsOptions(cell: contributorCell, handler: self.viewModel.contributorDidTap)

        let appSection = SettingsSection(title: "앱 설정", settingsOptions: [alertOption, fontOption])
        let serviceSection = SettingsSection(
            title: "서비스 정보",
            settingsOptions: [appVersionOption, openSourceOption, privacyOption, contributorsOption]
        )

        let sections: [SettingsSection] = [appSection, serviceSection]
        return sections
    }()

    // MARK: - Private Properties

    private var viewModel: SettingsViewModelProtocol!
    private var cancellables: Set<AnyCancellable> = []

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

        self.configureFont()
    }

    private func configureFont() {
        self.settingsSections.enumerated().forEach { index, section in
            guard let header = self.tableView.headerView(forSection: index) as? SettingsTableViewHeader else { return }
            header.font = .systemFont(ofSize: 16)

            section.settingsOptions.forEach { options in
                options.cell.font = .systemFont(ofSize: 16)
            }
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

        header.title = self.settingsSections[section].title
        return header
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = self.settingsSections[exist: indexPath.section],
              let cell = section.settingsOptions[exist: indexPath.row]?.cell else { return UITableViewCell() }

//        let separator = CALayer()
//
//        separator.frame = CGRect(x: 16, y: cell.contentView.frame.height - 1, width: self.tableView.frame.width-32, height: 1)
//        separator.backgroundColor = UIColor.dooldaLabel?.withAlphaComponent(0.2).cgColor
//        cell.contentView.layer.addSublayer(separator)
        cell.selectionStyle = .none
        return cell
    }
}
