//
//  AttachSubtitlesFlowModelImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 10.09.2022.
//

import Foundation

public final class AttachSubtitlesFlowModelImplFactory: AttachSubtitlesFlowModelFactory {

    // MARK: - Properties

    private let subtitlesPickerViewModelFactory: SubtitlesPickerViewModelFactory

    // MARK: - Initializers

    public init(subtitlesPickerViewModelFactory: SubtitlesPickerViewModelFactory) {

        self.subtitlesPickerViewModelFactory = subtitlesPickerViewModelFactory
    }

    // MARK: - Methods

    public func create(allowedDocumentTypes: [String]) -> AttachSubtitlesFlowModel {

        return AttachSubtitlesFlowModelImpl(
            allowedDocumentTypes: allowedDocumentTypes,
            subtitlesPickerViewModelFactory: subtitlesPickerViewModelFactory
        )
    }
}
