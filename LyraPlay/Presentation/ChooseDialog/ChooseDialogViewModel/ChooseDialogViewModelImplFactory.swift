//
//  ChooseDialogViewModelImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.09.2022.
//

import Foundation

public final class ChooseDialogViewModelImplFactory: ChooseDialogViewModelFactory {

    // MARK: - Initializers

    public init() {}

    // MARK: - Methods

    public func make(
        title: String,
        items: [ChooseDialogViewModelItem],
        delegate: ChooseDialogViewModelDelegate
    ) -> ChooseDialogViewModel {

        return ChooseDialogViewModelImpl(
            title: title,
            items: items,
            delegate: delegate
        )
    }
}
