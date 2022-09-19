//
//  PromptDialogViewModelImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.09.2022.
//

import Foundation
import Combine

public final class PromptDialogViewModelImpl: PromptDialogViewModel {

    // MARK: - Properties

    public var messageText: String
    public let submitText: String
    public let cancelText: String
    
    public let errorText = CurrentValueSubject<String?, Never>(nil)

    private weak var delegate: PromptDialogViewModelDelegate?

    // MARK: - Initializers

    public init(
        messageText: String,
        submitText: String,
        cancelText: String,
        delegate: PromptDialogViewModelDelegate
    ) {

        self.messageText = messageText
        self.submitText = submitText
        self.cancelText = cancelText
        self.delegate = delegate
    }
}

// MARK: - Input Methods

extension PromptDialogViewModelImpl {

    public func cancel() {

        delegate?.promptDialogViewModelDidCancel()
    }

    public func dispose() {

        delegate?.promptDialogViewModelDidDispose()
    }

    public func submit(value: String) {

        delegate?.promptDialogViewModelDidSubmit(value: value)
    }

    public func setErrorText(_ text: String?) {

        errorText.value = text
    }
}

// MARK: - Output Methods

extension PromptDialogViewModelImpl {

}
