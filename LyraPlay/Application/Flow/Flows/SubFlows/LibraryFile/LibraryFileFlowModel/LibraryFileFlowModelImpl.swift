//
//  LibraryFileFlowModelImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 08.09.22.
//

import Foundation
import Combine

public final class LibraryFileFlowModelImpl: LibraryFileFlowModel {
    
    // MARK: - Properties
    
    private let mediaId: UUID
    private let viewModelFactory: LibraryItemViewModelFactory
    private let attachSubtitlesFlowModelFactory: AttachSubtitlesFlowModelFactory
    
    public weak var delegate: LibraryFileFlowModelDelegate?
    
    public lazy var viewModel: LibraryItemViewModel = {
        viewModelFactory.make(mediaId: mediaId, delegate: self)
    } ()
    
    public var attachSubtitlesFlow = CurrentValueSubject<AttachSubtitlesFlowModel?, Never>(nil)
    
    // MARK: - Initializers
    
    public init(
        mediaId: UUID,
        delegate: LibraryFileFlowModelDelegate,
        viewModelFactory: LibraryItemViewModelFactory,
        attachSubtitlesFlowModelFactory: AttachSubtitlesFlowModelFactory
    ) {

        self.mediaId = mediaId
        self.delegate = delegate
        self.viewModelFactory = viewModelFactory
        self.attachSubtitlesFlowModelFactory = attachSubtitlesFlowModelFactory
    }
}

// MARK: - Input Methods

extension LibraryFileFlowModelImpl: LibraryItemViewModelDelegate {

    public func runAttachSubtitlesFlow() {
        
        guard self.attachSubtitlesFlow.value == nil else {
            return
        }
        
        self.attachSubtitlesFlow.value = attachSubtitlesFlowModelFactory.make(
            mediaId: mediaId,
            delegate: self
        )
    }
    
    public func finish() {
        
        self.attachSubtitlesFlow.value = nil
        self.delegate?.libraryFileFlowDidDispose()
    }
}

// MARK: - AttachSubtitlesFlowModelDelegate

extension LibraryFileFlowModelImpl: AttachSubtitlesFlowModelDelegate {
    
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
