//
//  FilterOptionBottomSheetViewController.swift
//  Doolda
//
//  Created by Seunghun Yang on 2021/11/21.
//

import UIKit

protocol FilterOptionBottomSheetViewControllerDelegate: AnyObject {
    func applyButtonDidTap(
        _ filterOptionBottomSheetViewController: FilterOptionBottomSheetViewController,
        authorFilter: DiaryAuthorFilter,
        orderFilter: DiaryOrderFilter
    )
}

class FilterOptionBottomSheetViewController: BottomSheetViewController {
    
    // MARK: - Subviews
    
    // MARK: - Private Properties
    
    private weak var delegate: FilterOptionBottomSheetViewControllerDelegate?
    
    // MARK: - Initializers
    
    convenience init(delegate: FilterOptionBottomSheetViewControllerDelegate?) {
        self.init(nibName: nil, bundle: nil)
        self.delegate = delegate
    }
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
    }
    
    // MARK: - Helpers
    
    private func configureUI() {
        self.detent = .small
        self.body.backgroundColor = .dooldaBackground
    }
}
