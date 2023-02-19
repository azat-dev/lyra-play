//
//  AttachSubtitlesFlowPresenterImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 10.09.2022.
//

import Foundation

public final class AttachSubtitlesFlowPresenterImplFactory: AttachSubtitlesFlowPresenterFactory {

    // MARK: - Properties

    private let subtitlesPickerViewFactory: FilesPickerViewFactory
    private let attachingSubtitlesProgressViewFactory: AttachingSubtitlesProgressViewFactory

    // MARK: - Initializers

    public init(
        subtitlesPickerViewFactory: FilesPickerViewFactory,
        attachingSubtitlesProgressViewFactory: AttachingSubtitlesProgressViewFactory
    ) {

        self.subtitlesPickerViewFactory = subtitlesPickerViewFactory
        self.attachingSubtitlesProgressViewFactory = attachingSubtitlesProgressViewFactory
    }

    // MARK: - Methods

    public func make(for flowModel: AttachSubtitlesFlowModel) -> AttachSubtitlesFlowPresenter {

        return AttachSubtitlesFlowPresenterImpl(
            flowModel: flowModel,
            subtitlesPickerViewFactory: subtitlesPickerViewFactory,
            attachingSubtitlesProgressViewFactory: attachingSubtitlesProgressViewFactory
        )
    }
}
