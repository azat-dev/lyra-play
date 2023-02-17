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
    private let subtitlesPickerViewFactory: FilesPickerViewFactory
    private let attachingSubtitlesProgressViewFactory: AttachingSubtitlesProgressViewFactory
    
    private var activeSubtitlesPickerView: FilesPickerViewController?
    
    private weak var progressView: UIViewController?
    private var observers = Set<AnyCancellable>()
    
    // MARK: - Initializers
    
    public init(
        flowModel: AttachSubtitlesFlowModel,
        subtitlesPickerViewFactory: FilesPickerViewFactory,
        attachingSubtitlesProgressViewFactory: AttachingSubtitlesProgressViewFactory
    ) {
        
        self.flowModel = flowModel
        self.subtitlesPickerViewFactory = subtitlesPickerViewFactory
        self.attachingSubtitlesProgressViewFactory = attachingSubtitlesProgressViewFactory
    }
    
    deinit {

        progressView = nil
        activeSubtitlesPickerView = nil
        observers.removeAll()
    }
}

// MARK: - Input Methods

extension AttachSubtitlesFlowPresenterImpl {
    
    public func present(at container: UINavigationController) {
        
        flowModel.progressViewModel
            .receive(on: RunLoop.main)
            .sink { [weak self] progressViewModel in
                
                guard let self = self else {
                    return
                }
                
                guard let progressViewModel = progressViewModel else {
                    
                    self.progressView?.dismiss(animated: true)
                    self.progressView = nil
                    return
                }
                
                let view = self.attachingSubtitlesProgressViewFactory.make(viewModel: progressViewModel)
                
                self.progressView = view
                container.modalPresentationStyle = .overCurrentContext
                container.modalTransitionStyle = .crossDissolve
                
                container.present(view, animated: true)
            }
            .store(in: &observers)
        
        let view = subtitlesPickerViewFactory.make(viewModel: flowModel.subtitlesPickerViewModel)
        activeSubtitlesPickerView = view
        
        container.present(view, animated: true)
    }
    
    public func dismiss() {
        
        progressView?.dismiss(animated: true)
        activeSubtitlesPickerView?.dismiss(animated: true)

        progressView = nil
        activeSubtitlesPickerView = nil
        observers.removeAll()
    }
}
