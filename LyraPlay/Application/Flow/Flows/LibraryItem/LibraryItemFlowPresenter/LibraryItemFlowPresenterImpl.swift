//
//  LibraryItemFlowPresenterImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 09.09.22.
//

import Foundation
import Combine
import UIKit

public final class LibraryItemFlowPresenterImpl: LibraryItemFlowPresenter {
    
    // MARK: - Properties
    
    private let flow: LibraryItemFlowModel
    private let libraryItemViewFactory: LibraryItemViewFactory
    private let attachSubtitlesFlowPresenterFactory: AttachSubtitlesFlowPresenterFactory
    
    private var observers = Set<AnyCancellable>()
    private var attachSubtitlesPresenter: AttachSubtitlesFlowPresenter?
    
    // MARK: - Initializers
    
    public init(
        flowModel: LibraryItemFlowModel,
        libraryItemViewFactory: LibraryItemViewFactory,
        attachSubtitlesFlowPresenterFactory: AttachSubtitlesFlowPresenterFactory
    ) {
        
        self.flow = flowModel
        self.libraryItemViewFactory = libraryItemViewFactory
        self.attachSubtitlesFlowPresenterFactory = attachSubtitlesFlowPresenterFactory
    }
    
    deinit {
        
        attachSubtitlesPresenter = nil
        observers.removeAll()
    }
}

// MARK: - Methods

extension LibraryItemFlowPresenterImpl {
    
    public func present(at container: UINavigationController) {
        
        flow.attachSubtitlesFlow
            .receive(on: RunLoop.main)
            .sink { [weak self] attachSubtitlesFlow in

                guard let self = self else {
                    return
                }
                
                guard let attachSubtitlesFlow = attachSubtitlesFlow else {
                    
                    self.attachSubtitlesPresenter?.dismiss()
                    self.attachSubtitlesPresenter = nil
                    return
                }
                
                let presenter = self.attachSubtitlesFlowPresenterFactory.create(for: attachSubtitlesFlow)
                self.attachSubtitlesPresenter = presenter
                presenter.present(at: container)
                
            }.store(in: &observers)
        
        let view = libraryItemViewFactory.create(viewModel: flow.viewModel)
        container.push(view)
    }
    
    public func dismiss() {
        
        attachSubtitlesPresenter?.dismiss()
        attachSubtitlesPresenter = nil
    }
}
