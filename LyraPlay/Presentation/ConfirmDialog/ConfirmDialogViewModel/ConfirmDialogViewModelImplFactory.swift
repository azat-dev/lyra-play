//
//  ConfirmDialogViewModelImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 15.09.2022.
//

import Foundation

public final class ConfirmDialogViewModelImplFactory: ConfirmDialogViewModelFactory {
    
    // MARK: - Initializers
    
    public init() {}
    
    // MARK: - Methods
    
    public func create(
        messageText: String,
        confirmText: String,
        cancelText: String,
        isDestructive: Bool,
        delegate: ConfirmDialogViewModelDelegate
    ) -> ConfirmDialogViewModel {
        
        return ConfirmDialogViewModelImpl(
            messageText: messageText,
            confirmText: confirmText,
            cancelText: cancelText,
            isDestructive: isDestructive,
            delegate: delegate
        )
    }
}
