//
//  AttachSubtitlesFlowPresenterImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 10.09.2022.
//

import Foundation

public final class AttachSubtitlesFlowPresenterImplFactory: AttachSubtitlesFlowPresenterFactory {

    // MARK: - Properties

    private let subtitlesPickerViewFactory: SubtitlesPickerViewFactory

    // MARK: - Initializers

    public init(subtitlesPickerViewFactory: SubtitlesPickerViewFactory) {

        self.subtitlesPickerViewFactory = subtitlesPickerViewFactory
    }

    // MARK: - Methods

    public func create(for flowModel: AttachSubtitlesFlowModel) -> AttachSubtitlesFlowPresenter {

        return AttachSubtitlesFlowPresenterImpl(
            flowModel: flowModel,
            subtitlesPickerViewFactory: subtitlesPickerViewFactory
        )
    }
}