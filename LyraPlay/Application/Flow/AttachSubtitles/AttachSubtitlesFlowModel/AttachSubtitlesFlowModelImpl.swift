//
//  AttachSubtitlesFlowModelImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 10.09.2022.
//

import Foundation

public final class AttachSubtitlesFlowModelImpl: AttachSubtitlesFlowModel {

    // MARK: - Properties

    private let subtitlesPickerViewModelFactory: SubtitlesPickerViewModelFactory
    private let allowedDocumentTypes: [String]
    
    public lazy var subtitlesPickerViewModel: SubtitlesPickerViewModel = {
        
        subtitlesPickerViewModelFactory.create(
            documentTypes: allowedDocumentTypes,
            delegate: self
        )
    } ()

    // MARK: - Initializers

    public init(
        allowedDocumentTypes: [String],
        subtitlesPickerViewModelFactory: SubtitlesPickerViewModelFactory
    ) {

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
        
    }
    
    public func subtitlesPickerDidChooseFile(url: URL) {
        
    }
}
