//
//  LibraryItemFlowPresenterImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 09.09.22.
//

import Foundation
import UIKit

public final class LibraryItemFlowPresenterImpl: LibraryItemFlowPresenter {
    
    private let flow: LibraryItemFlowModel
    private let libraryItemViewFactory: LibraryItemViewFactory
    
    public init(flowModel: LibraryItemFlowModel, libraryItemViewFactory: LibraryItemViewFactory) {
        
        self.flow = flowModel
        self.libraryItemViewFactory = libraryItemViewFactory
    }

    // MARK: - Methods
    public func present(at container: UINavigationController) {
        
        let view = libraryItemViewFactory.create(viewModel: flow.viewModel)
        container.push(view)
    }
}
