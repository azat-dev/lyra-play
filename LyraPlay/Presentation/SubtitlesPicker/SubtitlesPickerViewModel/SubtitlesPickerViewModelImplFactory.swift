//
//  SubtitlesPickerViewModelImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 09.09.2022.
//

import Foundation

public final class SubtitlesPickerViewModelImplFactory: SubtitlesPickerViewModelFactory {

    // MARK: - Initializers

    public init() {}

    // MARK: - Methods

    public func create(
        documentTypes: [String],
        delegate: SubtitlesPickerViewModelDelegate
    ) -> SubtitlesPickerViewModel {

        return SubtitlesPickerViewModelImpl(
            documentTypes: documentTypes,
            delegate: delegate
        )
    }
}
