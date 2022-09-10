//
//  LibraryItemFlowModelImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 08.09.22.
//

import Foundation
import Combine

public final class LibraryItemFlowModelImpl: LibraryItemFlowModel {
    
    // MARK: - Properties
    
    private let mediaId: UUID
    private let viewModelFactory: LibraryItemViewModelFactory
    private let attachSubtitlesFlowModelFactory: AttachSubtitlesFlowModelFactory
    
    public weak var delegate: LibraryItemFlowModelDelegate?
    
    public lazy var viewModel: LibraryItemViewModel = {
        viewModelFactory.create(mediaId: mediaId, delegate: self)
    } ()
    
    public var attachSubtitlesFlow = CurrentValueSubject<AttachSubtitlesFlowModel?, Never>(nil)
    
    // MARK: - Initializers
    
    public init(
        mediaId: UUID,
        viewModelFactory: LibraryItemViewModelFactory,
        attachSubtitlesFlowModelFactory: AttachSubtitlesFlowModelFactory
    ) {

        self.mediaId = mediaId
        self.viewModelFactory = viewModelFactory
        self.attachSubtitlesFlowModelFactory = attachSubtitlesFlowModelFactory
    }
}

// MARK: - Input Methods

extension LibraryItemFlowModelImpl: LibraryItemViewModelDelegate {

    public func runAttachSubtitlesFlow() {
        
        guard self.attachSubtitlesFlow.value == nil else {
            return
        }
        
        self.attachSubtitlesFlow.value = attachSubtitlesFlowModelFactory.create(
            mediaId: mediaId,
            delegate: self
        )
    }
    
    public func finish() {
        
        self.delegate?.didFinishLibraryItemFlow()
    }
}

// MARK: - AttachSubtitlesFlowModelDelegate

extension LibraryItemFlowModelImpl: AttachSubtitlesFlowModelDelegate {
    
    public func attachSubtitlesFlowDidAttach() {
        
        attachSubtitlesFlow.value = nil
    }
    
    public func attachSubtitlesFlowDidFinish() {
        
        attachSubtitlesFlow.value = nil
    }
    
    public func attachSubtitlesFlowDidCancel() {
        
        attachSubtitlesFlow.value = nil
    }
}
