//
//  AttachSubtitlesFlowModelImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 10.09.2022.
//

import Foundation

public final class AttachSubtitlesFlowModelImpl: AttachSubtitlesFlowModel {

    // MARK: - Properties

    private let mediaId: UUID
    private let subtitlesPickerViewModelFactory: SubtitlesPickerViewModelFactory
    private let allowedDocumentTypes: [String]
    private weak var delegate: AttachSubtitlesFlowModelDelegate?
    
    public lazy var subtitlesPickerViewModel: SubtitlesPickerViewModel = {
        
        subtitlesPickerViewModelFactory.create(
            documentTypes: allowedDocumentTypes,
            delegate: self
        )
    } ()

    // MARK: - Initializers

    public init(
        mediaId: UUID,
        delegate: AttachSubtitlesFlowModelDelegate,
        allowedDocumentTypes: [String],
        subtitlesPickerViewModelFactory: SubtitlesPickerViewModelFactory
    ) {

        self.mediaId = mediaId
        self.delegate = delegate
        self.allowedDocumentTypes = allowedDocumentTypes
        self.subtitlesPickerViewModelFactory = subtitlesPickerViewModelFactory
    }
}

// MARK: - Input Methods

extension AttachSubtitlesFlowModelImpl {

}

// MARK: - SubtitlesPickerViewModelDelegate

extension AttachSubtitlesFlowModelImpl: SubtitlesPickerViewModelDelegate {

    public func subtitlesPickerDidCancel() {
        
        delegate?.attachSubtitlesFlowDidCancel()
    }
    
    public func subtitlesPickerDidChooseFile(url: URL) {

        delegate?.attachSubtitlesFlowDidAttach()
    }
    
    public func subtitlesDidFinish() {
        
        delegate?.attachSubtitlesFlowDidFinish()
    }
}
