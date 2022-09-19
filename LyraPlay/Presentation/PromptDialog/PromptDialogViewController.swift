//
//  PromptDialogViewController.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 20.09.22.
//

import Foundation
import UIKit

public final class PromptDialogViewController: UIAlertController, PromptDialogView {

    // MARK: - Properties
    
    private var viewModel: ViewModel!

    // MARK: - Methods
    
    public override func viewDidDisappear(_ animated: Bool) {

        super.viewDidDisappear(animated)
        viewModel.dispose()
    }
    
    public static func create(viewModel: ViewModel) -> PromptDialogViewController {
        
        let alert = PromptDialogViewController(
            title: viewModel.messageText,
            message: nil,
            preferredStyle: .alert
        )
        
        alert.viewModel = viewModel
        
        alert.addTextField { textField in
            
            textField.becomeFirstResponder()
        }
        
        let confirmAction = UIAlertAction(
            title: viewModel.submitText,
            style: .default,
            handler: { _ in viewModel.submit(value: "") }
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
