//
//  ChooseDialogViewController.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.09.22.
//

import Foundation
import UIKit

public final class ChooseDialogViewController: UIAlertController, ChooseDialogView {

    // MARK: - Properties
    
    private var viewModel: ViewModel!

    // MARK: - Methods
    
    public override func viewDidDisappear(_ animated: Bool) {

        super.viewDidDisappear(animated)
        viewModel.dispose()
    }
    
    public static func create(viewModel: ViewModel) -> ChooseDialogViewController {
        
        let alert = ChooseDialogViewController(
            title: nil,
            message: viewModel.title,
            preferredStyle: .actionSheet
        )
        
        alert.viewModel = viewModel
        
        for item in viewModel.items {
            
            let action = UIAlertAction(
                title: item.title,
                style: .default,
                handler: { [weak viewModel] _ in viewModel?.choose(itemId: item.id) }
            )
            
            alert.addAction(action)
        }
        
        let action = UIAlertAction(
            title: "Cancel",
            style: .cancel,
            handler: { [weak viewModel] _ in viewModel?.cancel() }
        )
        
        alert.addAction(action)
        
        return alert
    }
}
