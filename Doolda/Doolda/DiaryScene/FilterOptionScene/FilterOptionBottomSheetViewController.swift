//
//  FilterOptionBottomSheetViewController.swift
//  Doolda
//
//  Created by Seunghun Yang on 2021/11/21.
//

import Combine
import UIKit

import SnapKit

protocol FilterOptionBottomSheetViewControllerDelegate: AnyObject {
    func applyButtonDidTap(
        _ filterOptionBottomSheetViewController: FilterOptionBottomSheetViewController,
        authorFilter: DiaryAuthorFilter,
        orderFilter: DiaryOrderFilter
    )
    
    func filterOptionDidChange(
        _ filterOptionBottomSheetViewController: FilterOptionBottomSheetViewController,
        authorFilter: DiaryAuthorFilter,
        orderFilter: DiaryOrderFilter
    )
    
    func filterBottomSheetWillDismiss(_ filteredOptionBottomSheetController: FilterOptionBottomSheetViewController)
}

class FilterOptionBottomSheetViewController: BottomSheetViewController {
    
    // MARK: - Subviews
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "다이어리 필터"
        return label
    }()
    
    private lazy var authorFilterOptionSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: DiaryAuthorFilter.titles)
        segmentedControl.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 14)], for: .normal)
        return segmentedControl
    }()
    
    private lazy var orderFilterOptionSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: DiaryOrderFilter.titles)
        segmentedControl.setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 14)], for: .normal)
        return segmentedControl
    }()
    
    private lazy var applyButton: UIButton = {
        let button = UIButton()
        button.setTitle("적용", for: .normal)
        button.setTitleColor(.dooldaLabel, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.backgroundColor = .dooldaHighlighted
        button.layer.cornerRadius = 22
        return button
    }()
    
    // MARK: - Private Properties
    
    private var viewModel: FilterOptionBottomSheetViewModel!
    private weak var delegate: FilterOptionBottomSheetViewControllerDelegate?
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Initializers
    
    convenience init(
        viewModel: FilterOptionBottomSheetViewModel,
        delegate: FilterOptionBottomSheetViewControllerDelegate?
    ) {
        self.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
        self.delegate = delegate
    }
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
        self.bindUI()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.delegate?.filterBottomSheetWillDismiss(self)
    }
    
    // MARK: - Helpers
    
    private func configureUI() {
        self.detent = .small
        self.body.backgroundColor = .dooldaBackground
        
        self.body.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.centerX.equalToSuperview()
        }
        
        self.body.addSubview(self.authorFilterOptionSegmentedControl)
        self.authorFilterOptionSegmentedControl.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(8)
            make.height.equalTo(30)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }

        self.body.addSubview(self.orderFilterOptionSegmentedControl)
        self.orderFilterOptionSegmentedControl.snp.makeConstraints { make in
            make.top.equalTo(self.authorFilterOptionSegmentedControl.snp.bottom).offset(8)
            make.height.equalTo(30)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
        }
        
        self.body.addSubview(self.applyButton)
        self.applyButton.snp.makeConstraints { make in
            make.top.equalTo(self.orderFilterOptionSegmentedControl.snp.bottom).offset(16)
            make.height.equalTo(44)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-32)
        }
    }
    
    private func bindUI() {
        self.viewModel.authorFilterPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] authorFilter in
                self?.authorFilterOptionSegmentedControl.selectedSegmentIndex = DiaryAuthorFilter.indexOf(authorFilter: authorFilter)
            }
            .store(in: &self.cancellables)
        
        self.viewModel.orderFilterPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] orderFilter in
                self?.orderFilterOptionSegmentedControl.selectedSegmentIndex = DiaryOrderFilter.indexOf(orderFilter: orderFilter)
            }
            .store(in: &self.cancellables)
        
        self.authorFilterOptionSegmentedControl.publisher(for: .valueChanged)
            .sink { [weak self] _ in
                guard let index = self?.authorFilterOptionSegmentedControl.selectedSegmentIndex else { return }
                self?.viewModel.authorFilterIndexValueDidChange(index)
            }
            .store(in: &self.cancellables)
        
        self.orderFilterOptionSegmentedControl.publisher(for: .valueChanged)
            .sink { [weak self] _ in
                guard let index = self?.orderFilterOptionSegmentedControl.selectedSegmentIndex else { return }
                self?.viewModel.orderFilterIndexValueDidChange(index)
            }
            .store(in: &self.cancellables)
        
        Publishers.CombineLatest3(
            self.applyButton.publisher(for: .touchUpInside),
            self.viewModel.authorFilterPublisher,
            self.viewModel.orderFilterPublisher
        )
            .sink { [weak self] _, authorFilter, orderFilter in
                guard let self = self else { return }
                self.delegate?.applyButtonDidTap(self, authorFilter: authorFilter, orderFilter: orderFilter)
                self.dismiss(animated: true)
            }
            .store(in: &self.cancellables)
        
        Publishers.CombineLatest(self.viewModel.authorFilterPublisher, self.viewModel.orderFilterPublisher)
            .sink { [weak self] authorFilter, orderFilter in
                guard let self = self else { return }
                self.delegate?.filterOptionDidChange(self, authorFilter: authorFilter, orderFilter: orderFilter)
            }
            .store(in: &self.cancellables)
    }
}
