//
//  AttachSubtitlesFlowPresenterImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 10.09.2022.
//

import Foundation
import UIKit

public final class AttachSubtitlesFlowPresenterImpl: AttachSubtitlesFlowPresenter {

    // MARK: - Properties

    private let flowModel: AttachSubtitlesFlowModel
    private let subtitlesPickerViewFactory: SubtitlesPickerViewFactory

    // MARK: - Initializers

    public init(
        flowModel: AttachSubtitlesFlowModel,
        subtitlesPickerViewFactory: SubtitlesPickerViewFactory
    ) {

        self.flowModel = flowModel
        self.subtitlesPickerViewFactory = subtitlesPickerViewFactory
    }
}

// MARK: - Input Methods

extension AttachSubtitlesFlowPresenterImpl {

    public func present(at container: UINavigationController) {

        let view = subtitlesPickerViewFactory.create(viewModel: flowModel.subtitlesPickerViewModel)
        container.present(view, animated: true)
    }
}
