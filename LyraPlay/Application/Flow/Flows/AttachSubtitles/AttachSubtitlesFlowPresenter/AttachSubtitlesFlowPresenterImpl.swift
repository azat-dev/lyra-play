//
//  AttachSubtitlesFlowPresenterImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 10.09.2022.
//

import Foundation
import UIKit
import Combine

public final class AttachSubtitlesFlowPresenterImpl: AttachSubtitlesFlowPresenter {

    // MARK: - Properties

    private let flowModel: AttachSubtitlesFlowModel
    private let subtitlesPickerViewFactory: SubtitlesPickerViewFactory
    private let attachingSubtitlesProgressViewFactory: AttachingSubtitlesProgressViewFactory
    
    private var activeSubtitlesPickerView: FilesPickerViewController?
    
    private var progressObserver: AnyCancellable?
    
    private weak var progressView: UIViewController?
    
    // MARK: - Initializers

    public init(
        flowModel: AttachSubtitlesFlowModel,
        subtitlesPickerViewFactory: SubtitlesPickerViewFactory,
        attachingSubtitlesProgressViewFactory: AttachingSubtitlesProgressViewFactory
    ) {

        self.flowModel = flowModel
        self.subtitlesPickerViewFactory = subtitlesPickerViewFactory
        self.attachingSubtitlesProgressViewFactory = attachingSubtitlesProgressViewFactory
    }
}

// MARK: - Input Methods

extension AttachSubtitlesFlowPresenterImpl {

    public func present(at container: UINavigationController) {

        progressObserver = flowModel.progressViewModel
            .receive(on: RunLoop.main)
            .sink { progressViewModel in
                
                guard let progressViewModel = progressViewModel else {
                    
                    self.progressView?.dismiss(animated: true)
                    return
                }
                
                let view = self.attachingSubtitlesProgressViewFactory.create(viewModel: progressViewModel)
                
                self.progressView = view
                container.modalPresentationStyle = .overCurrentContext
                container.modalTransitionStyle = .crossDissolve
                
                container.present(view, animated: true)
            }
        
        let view = subtitlesPickerViewFactory.create(viewModel: flowModel.subtitlesPickerViewModel)
        activeSubtitlesPickerView = view
        
        container.present(view, animated: true)
    }
    
    public func dismiss() {
        
        progressView?.dismiss(animated: true)
        activeSubtitlesPickerView?.dismiss(animated: true)
    }
}
