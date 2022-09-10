//
//  AttachSubtitlesFlowModelImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 10.09.2022.
//

import Foundation

public final class AttachSubtitlesFlowModelImplFactory: AttachSubtitlesFlowModelFactory {

    // MARK: - Properties

    private let allowedDocumentTypes: [String]
    private let subtitlesPickerViewModelFactory: SubtitlesPickerViewModelFactory
    
    // MARK: - Initializers

    public init(
        allowedDocumentTypes: [String],
        subtitlesPickerViewModelFactory: SubtitlesPickerViewModelFactory
    ) {

        self.allowedDocumentTypes = allowedDocumentTypes
        self.subtitlesPickerViewModelFactory = subtitlesPickerViewModelFactory
    }

    // MARK: - Methods

    public func create(mediaId: UUID, delegate: AttachSubtitlesFlowModelDelegate) -> AttachSubtitlesFlowModel {

        return AttachSubtitlesFlowModelImpl(
            mediaId: mediaId,
            delegate: delegate,
            allowedDocumentTypes: allowedDocumentTypes,
            subtitlesPickerViewModelFactory: subtitlesPickerViewModelFactory
        )
    }
}
