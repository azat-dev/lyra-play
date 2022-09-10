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
    private let subtitlesPickerViewModelFactory: FilesPickerViewModelFactory
    private let attachingSubtitlesProgressViewModelFactory: AttachingSubtitlesProgressViewModelFactory
    private let importSubtitlesUseCaseFactory: ImportSubtitlesUseCaseImplFactory
    
    // MARK: - Initializers

    public init(
        allowedDocumentTypes: [String],
        subtitlesPickerViewModelFactory: FilesPickerViewModelFactory,
        attachingSubtitlesProgressViewModelFactory: AttachingSubtitlesProgressViewModelFactory,
        importSubtitlesUseCaseFactory: ImportSubtitlesUseCaseImplFactory
    ) {

        self.allowedDocumentTypes = allowedDocumentTypes
        self.subtitlesPickerViewModelFactory = subtitlesPickerViewModelFactory
        self.attachingSubtitlesProgressViewModelFactory = attachingSubtitlesProgressViewModelFactory
        self.importSubtitlesUseCaseFactory = importSubtitlesUseCaseFactory
    }

    // MARK: - Methods

    public func create(mediaId: UUID, delegate: AttachSubtitlesFlowModelDelegate) -> AttachSubtitlesFlowModel {

        return AttachSubtitlesFlowModelImpl(
            mediaId: mediaId,
            delegate: delegate,
            allowedDocumentTypes: allowedDocumentTypes,
            subtitlesPickerViewModelFactory: subtitlesPickerViewModelFactory,
            attachingSubtitlesProgressViewModelFactory: attachingSubtitlesProgressViewModelFactory,
            importSubtitlesUseCaseFactory: importSubtitlesUseCaseFactory
        )
    }
}
