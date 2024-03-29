//
//  ChooseDialogViewModelImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.09.2022.
//

import Foundation

public final class ChooseDialogViewModelImpl: ChooseDialogViewModel {

    // MARK: - Properties

    public let title: String
    public let items: [ChooseDialogViewModelItem]
    
    private weak var delegate: ChooseDialogViewModelDelegate?

    // MARK: - Initializers

    public init(
        title: String,
        items: [ChooseDialogViewModelItem],
        delegate: ChooseDialogViewModelDelegate
    ) {

        self.title = title
        self.items = items
        self.delegate = delegate
    }
}

// MARK: - Input Methods

extension ChooseDialogViewModelImpl {

    public func choose(itemId: String) {

        delegate?.chooseDialogViewModelDidChoose(itemId: itemId)
    }

    public func cancel() {

        delegate?.chooseDialogViewModelDidCancel()
    }

    public func dispose() {

        delegate?.chooseDialogViewModelDidDispose()
    }
}
