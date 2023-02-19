//
//  PromptDialogViewModelImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.09.2022.
//

import Foundation

public final class PromptDialogViewModelImplFactory: PromptDialogViewModelFactory {

    // MARK: - Initializers

    public init() {}

    // MARK: - Methods

    public func make(
        messageText: String,
        submitText: String,
        cancelText: String,
        delegate: PromptDialogViewModelDelegate
    ) -> PromptDialogViewModel {

        return PromptDialogViewModelImpl(
            messageText: messageText,
            submitText: submitText,
            cancelText: cancelText,
            delegate: delegate
        )
    }
}
