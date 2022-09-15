//
//  ConfirmDialogViewModelFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 15.09.2022.
//

public protocol ConfirmDialogViewModelFactory {

    func create(
        messageText: String,
        confirmText: String,
        cancelText: String,
        isDestructive: Bool,
        delegate: ConfirmDialogViewModelDelegate
    ) -> ConfirmDialogViewModel
}
