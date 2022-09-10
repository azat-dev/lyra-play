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
    
    private var attachSubtitlesFlowObserver: AnyCancellable?
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
    
    // MARK: - Methods
    
    public func present(at container: UINavigationController) {
        
        attachSubtitlesFlowObserver = flow.attachSubtitlesFlow
            .receive(on: RunLoop.main)
            .sink { attachSubtitlesFlow in
                
                guard let attachSubtitlesFlow = attachSubtitlesFlow else {
                    
                    self.attachSubtitlesPresenter?.dismiss()
                    return
                }
                
                let presenter = self.attachSubtitlesFlowPresenterFactory.create(for: attachSubtitlesFlow)
                presenter.present(at: container)
            }
        
        let view = libraryItemViewFactory.create(viewModel: flow.viewModel)
        container.push(view)
    }
}
