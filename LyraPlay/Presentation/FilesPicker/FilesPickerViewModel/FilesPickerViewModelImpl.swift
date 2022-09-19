//
//  FilesPickerViewModelImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 09.09.2022.
//

import Foundation

public final class FilesPickerViewModelImpl: FilesPickerViewModel {

    // MARK: - Properties

    public weak var delegate: FilesPickerViewModelDelegate?
    
    public let allowsMultipleSelection: Bool
    public let documentTypes: [String]

    // MARK: - Initializers

    public init(documentTypes: [String], allowsMultipleSelection: Bool, delegate: FilesPickerViewModelDelegate) {
        
        self.documentTypes = documentTypes
        self.allowsMultipleSelection = allowsMultipleSelection
        self.delegate = delegate
    }
}

// MARK: - Input Methods

extension FilesPickerViewModelImpl {

    public func choose(urls: [URL]) {

        delegate?.filesPickerDidChoose(urls: urls)
    }

    public func cancel() {

        delegate?.filesPickerDidCancel()
    }
    
    public func dispose() {
        
        delegate?.filesPickerDidDispose()
    }
}
