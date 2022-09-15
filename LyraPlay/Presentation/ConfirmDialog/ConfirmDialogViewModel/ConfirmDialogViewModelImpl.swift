//
//  ConfirmDialogViewModelImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 15.09.2022.
//

import Foundation

public final class ConfirmDialogViewModelImpl: ConfirmDialogViewModel {

    // MARK: - Properties

    private weak var delegate: ConfirmDialogViewModelDelegate?
    
    public var messageText: String = ""
    public var confirmText: String = .init()
    public var cancelText: String = .init()

    // MARK: - Initializers

    public init(
        messageText: String,
        confirmText: String,
        cancelText: String,
        delegate: ConfirmDialogViewModelDelegate
    ) {

        self.messageText = messageText
        self.confirmText = confirmText
        self.cancelText = cancelText
        self.delegate = delegate
    }
}

// MARK: - Input Methods

extension ConfirmDialogViewModelImpl {

    public func confirm() {

        delegate?.confirmDialogDidConfirm()
    }

    public func cancel() {

        delegate?.confirmDialogDidCancel()
    }
    
    public func dispose() {

        delegate?.confirmDialogDispose()
    }
}
