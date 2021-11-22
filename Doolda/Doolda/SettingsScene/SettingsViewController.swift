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

    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.setImage(.left, for: .normal)
        return button
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(SettingsTableViewCell.self, forCellReuseIdentifier: SettingsTableViewCell.identifier)
        tableView.backgroundColor = .clear
        tableView.separatorColor = .dooldaLabel?.withAlphaComponent(0.5)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
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
        self.bindUI()
    }

    // MARK: - Helpers

    private func configureUI() {
        self.view.backgroundColor = .dooldaBackground
        self.title = "설정"
        self.navigationController?.navigationBar.barTintColor = .dooldaLabel
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: self.backButton)

        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func bindUI() {
        self.backButton.publisher(for: .touchUpInside)
            .sink { [weak self] _ in
                self?.viewModel.backButtonDidTap()
            }
            .store(in: &self.cancellables)
    }

}

extension SettingsViewController: UITableViewDelegate {
   
}

extension SettingsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.settingsSections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard section < self.settingsSections.count else { return 0 }
        return  self.settingsSections[section].settingsOptions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.section < self.settingsSections.count else { return UITableViewCell() }

        let section = self.settingsSections[indexPath.section]
        guard indexPath.row < section.settingsOptions.count else { return UITableViewCell() }

        let settingsOption = section.settingsOptions
        return settingsOption[indexPath.row].cell
    }
}
