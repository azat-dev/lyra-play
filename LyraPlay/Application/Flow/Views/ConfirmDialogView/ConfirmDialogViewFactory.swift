//
//  ConfirmDialogViewFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 15.09.2022.
//

public protocol ConfirmDialogViewFactory {

    func make(viewModel: ConfirmDialogViewModel) -> ConfirmDialogViewController
}
