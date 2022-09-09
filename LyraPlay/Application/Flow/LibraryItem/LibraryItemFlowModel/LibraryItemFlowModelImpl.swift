//
//  LibraryItemFlowModelImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 08.09.22.
//

import Foundation

public final class LibraryItemFlowModelImpl: LibraryItemFlowModel {
    
    private let mediaId: UUID
    private var viewModelFactory: LibraryItemViewModelFactory
    
    public lazy var viewModel: LibraryItemViewModel = {
        
        viewModelFactory.create(mediaId: mediaId, delegate: self)
    } ()
    
    public init(
        mediaId: UUID,
        viewModelFactory: LibraryItemViewModelFactory
    ) {

        self.mediaId = mediaId
        self.viewModelFactory = viewModelFactory
    }
}

// MARK: - Input Methods

extension LibraryItemFlowModelImpl: LibraryItemViewModelDelegate {
    
    public func runAttachSubtitlesFlow(completion: @escaping (_ url: URL?) -> Void) {
        
    }
}
