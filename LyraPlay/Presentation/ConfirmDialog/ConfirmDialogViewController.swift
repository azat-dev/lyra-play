//
//  ConfirmDialogViewController.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 15.09.22.
//

import Foundation
import UIKit

public final class ConfirmDialogViewController: UIAlertController, ConfirmDialogView {

    // MARK: - Properties
    
    private var viewModel: ViewModel!

    // MARK: - Methods
    
    public override func viewDidDisappear(_ animated: Bool) {

        super.viewDidDisappear(animated)
        viewModel.dispose()
    }
    
    public static func create(viewModel: ViewModel) -> ConfirmDialogViewController {
        
        let alert = ConfirmDialogViewController(
            title: nil,
            message: viewModel.messageText,
            preferredStyle: .alert
        )
        
        alert.viewModel = viewModel
        
        let confirmAction = UIAlertAction(
            title: viewModel.confirmText,
            style: viewModel.isDestructive ? .destructive : .default,
            handler: { _ in viewModel.confirm() }
        )
        
        let cancelAction = UIAlertAction(
            title: viewModel.cancelText,
            style: .cancel,
            handler: { _ in viewModel.cancel() }
        )

        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        
        return alert
    }
}
