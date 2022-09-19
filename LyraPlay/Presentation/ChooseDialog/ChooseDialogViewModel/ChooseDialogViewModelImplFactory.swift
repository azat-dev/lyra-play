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

    public func create(
        items: [ChooseDialogViewModelItem],
        delegate: ChooseDialogViewModelDelegate
    ) -> ChooseDialogViewModel {

        return ChooseDialogViewModelImpl(
            items: items,
            delegate: delegate
        )
    }
}
