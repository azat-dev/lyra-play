//
//  ConfirmDialogViewModel.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 15.09.2022.
//

import Foundation

public protocol ConfirmDialogViewModelDelegate: AnyObject {
    
    func confirmDialogDidConfirm()
    
    func confirmDialogDidCancel()
    
    func confirmDialogDispose()
}

public protocol ConfirmDialogViewModelInput: AnyObject {

    func confirm()

    func cancel()
    
    func dispose()
}

public protocol ConfirmDialogViewModelOutput: AnyObject {

    var messageText: String { get }

    var confirmText: String { get }

    var cancelText: String { get }
}

public protocol ConfirmDialogViewModel: ConfirmDialogViewModelOutput, ConfirmDialogViewModelInput {}
