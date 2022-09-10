//
//  SubtitlesPickerViewModelImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 09.09.2022.
//

import Foundation

public final class SubtitlesPickerViewModelImpl: SubtitlesPickerViewModel {

    // MARK: - Properties

    public weak var delegate: SubtitlesPickerViewModelDelegate?
    
    public let documentTypes: [String]

    // MARK: - Initializers

    public init(documentTypes: [String], delegate: SubtitlesPickerViewModelDelegate) {
        
        self.documentTypes = documentTypes
        self.delegate = delegate
    }
}

// MARK: - Input Methods

extension SubtitlesPickerViewModelImpl {

    public func chooseFile(url: URL) {

        delegate?.subtitlesPickerDidChooseFile(url: url)
    }

    public func cancel() {

        delegate?.subtitlesPickerDidCancel()
    }
}
