//
//  LibraryItemViewControllerFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 03.07.22.
//

import Foundation

public final class LibraryItemViewControllerFactory {
    
    private var coordinator: LibraryItemCoordinator
    private var showMediaInfoCase: ShowMediaInfoUseCase
    
    init(coordnator: LibraryItemCoordinator, showMediaInfoUseCase: ShowMediaInfoUseCase) {
        
        self.coordinator = coordnator
        self.showMediaInfoCase = showMediaInfoUseCase
    }
    
    public func build(with trackId: UUID) -> LibraryItemViewController {
        
        let viewModel = DefaultLibraryItemViewModel(
            trackId: trackId,
            coordinator: coordinator,
            showMediaInfoUseCase: showMediaInfoCase
        )
        
        return LibraryItemViewController(viewModel: viewModel)
    }
}
