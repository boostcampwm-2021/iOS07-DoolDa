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
        alertCell.title = "앱 실행 중 알림"
        let alertOption = SettingsOptions(cell: alertCell, handler: nil)

        let fontCell = SettingsTableViewCell(style: .detail)
        fontCell.title = "폰트 설정"
        let fontOption = SettingsOptions(cell: fontCell, handler: self.viewModel.fontCellDidTap)

        let versionCell = SettingsTableViewCell(style: .detail)
        versionCell.title = "앱 현재 버전"
        versionCell.detailText = DooldaInfoType.appVersion.rawValue
        let appVersionOption = SettingsOptions(cell: versionCell, handler: nil)

        let openSourceCell = SettingsTableViewCell(style: .disclosure)
        openSourceCell.title = "Open Source License"
        let openSourceOption = SettingsOptions(cell: openSourceCell, handler: self.viewModel.openSourceCellDidTap)

        let privacyCell = SettingsTableViewCell(style: .disclosure)
        privacyCell.title = "개인 정보 처리 방침"
        let privacyOption = SettingsOptions(cell: privacyCell, handler: self.viewModel.privacyCellDidTap)

        let contributorCell = SettingsTableViewCell(style: .disclosure)
        contributorCell.title = "만든 사람들"
        let contributorsOption = SettingsOptions(cell: contributorCell, handler: self.viewModel.contributorCellDidTap)

        let unpairCell = SettingsTableViewCell(style: .normal)
        unpairCell.title = "친구 끊기"
        let unpairOption = SettingsOptions(cell: unpairCell, handler: self.showUnpairAlert)

        let logoutCell = SettingsTableViewCell(style: .normal)
        logoutCell.title = "로그아웃"
        let logoutOption = SettingsOptions(cell: logoutCell, handler: self.showLogoutAlert)

        let deleteAccountCell = SettingsTableViewCell(style: .normal)
        deleteAccountCell.title = "회원 탈퇴"
        let deleteAccountOption = SettingsOptions(cell: deleteAccountCell, handler: self.showDeleteAcountAlert)

        let appSection = SettingsSection(title: "앱 설정", settingsOptions: [alertOption, fontOption])
        let serviceSection = SettingsSection(
            title: "서비스 정보",
            settingsOptions: [appVersionOption, openSourceOption, privacyOption, contributorsOption]
        )
        let dangerSection = SettingsSection(
            title: "Danger zone",
            settingsOptions: [unpairOption, logoutOption, deleteAccountOption]
        )

        let sections: [SettingsSection] = [appSection, serviceSection, dangerSection]
        return sections
    }()

    // MARK: - Override Properties

    override var prefersStatusBarHidden: Bool { return true }

    // MARK: - Private Properties

    private var viewModel: SettingsViewModelProtocol!
    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Initializers

    convenience init(viewModel: SettingsViewModelProtocol) {
        self.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    deinit {
        print(#file, "DEINIT")
        self.viewModel.deinitRequested()
    }
    
    // MARK: - LifeCycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
        self.configureFont()
        self.bindUI()
        self.viewModel.settingsViewDidLoad()
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

    private func configureFont() {
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)]

        self.settingsSections.enumerated().forEach { index, section in
            guard let header = self.tableView.headerView(forSection: index) as? SettingsTableViewHeader else { return }
            header.font = .systemFont(ofSize: 17)

            section.settingsOptions.forEach { options in
                options.cell.font = .systemFont(ofSize: 16)
            }
        }
    }

    private func bindUI() {
        self.viewModel.pushNotificationStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isPushNotificationOn in
                guard let isPushNotificationOn = isPushNotificationOn,
                      let section = self?.settingsSections[exist: 0],
                      let alertCell = section.settingsOptions[exist: 0]?.cell else { return }
                alertCell.switchControl.isOn = isPushNotificationOn
            }
            .store(in: &self.cancellables)

        self.viewModel.selectedFontPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] selectedFont in
                guard let section = self?.settingsSections[exist: 0],
                      let fontCell = section.settingsOptions[exist: 1]?.cell else { return }
                fontCell.detailText = selectedFont?.displayName
            }
            .store(in: &self.cancellables)

        self.viewModel.errorPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                guard let error = error else { return }
                let alert = UIAlertController.defaultAlert(title: "오류", message: error.localizedDescription) { _ in }
                self?.present(alert, animated: true, completion: nil)
            }
            .store(in: &self.cancellables)

        guard let section = self.settingsSections[exist: 0],
              let alertCell = section.settingsOptions[exist: 0]?.cell else { return }
        
        alertCell.switchControl.publisher(for: .valueChanged)
            .sink { [weak self] _ in
                self?.viewModel.pushNotificationDidToggle(alertCell.switchControl.isOn)
            }
            .store(in: &self.cancellables)
        
        NotificationCenter.default.publisher(for: GlobalFontUseCase.Notifications.globalFontDidSet, object: nil)
            .sink { [weak self] _ in
                self?.configureFont()
            }
            .store(in: &self.cancellables)
    }
    
    private func showUnpairAlert() {
        let alert = UIAlertController.selectAlert(
            title: "친구 끊기",
            message: "정말 친구와 연결을 끊으시겠습니까?\n친구와 함께한 모든 다이어리가 지워집니다.",
            leftActionTitle: "취소",
            rightActionTitle: "확인" ) { _ in
                self.viewModel.unpairButtonDidTap()
            }
        self.present(alert, animated: true, completion: nil)
    }

    private func showLogoutAlert() {
        let alert = UIAlertController.selectAlert(
            title: "로그아웃",
            message: "정말 로그아웃 하시겠습니까?",
            leftActionTitle: "취소",
            rightActionTitle: "확인") { _ in
                self.viewModel.logoutButtonDidTap()
            }
        self.present(alert, animated: true, completion: nil)
    }

    private func showDeleteAcountAlert() {
        let alert = UIAlertController.selectAlert(
            title: "회원 탈퇴",
            message: "정말 회원 탈퇴하시겠습니까?\n회원님의 모든 데이터가 지워집니다.",
            leftActionTitle: "취소",
            rightActionTitle: "확인" ) { _ in
                self.viewModel.deleteAccountButtonDidTap()
            }
        self.present(alert, animated: true, completion: nil)
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

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == self.settingsSections.count - 1 { return 100 }
        return 0
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(
                withIdentifier: SettingsTableViewHeader.identifier
              ) as? SettingsTableViewHeader else { return nil }
        if section == 2 { header.textColor = .dooldaWarning }
        header.title = self.settingsSections[section].title
        return header
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = self.settingsSections[exist: indexPath.section],
              let cell = section.settingsOptions[exist: indexPath.row]?.cell else { return UITableViewCell() }
        cell.selectionStyle = .none
        return cell
    }
}

extension SettingsViewController: FontPickerViewControllerDelegate {
    func fontDidSelect(_ font: FontType) {
        self.viewModel.fontTypeDidChanged(font.name)
    }
}
