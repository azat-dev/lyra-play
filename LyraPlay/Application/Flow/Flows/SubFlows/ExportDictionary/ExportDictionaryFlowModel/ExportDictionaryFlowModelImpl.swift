//
//  ExportDictionaryFlowModelImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.01.2023.
//

import Foundation
import Combine

public final class ExportDictionaryFlowModelImpl: ExportDictionaryFlowModel {

    // MARK: - Properties

    private weak var delegate: ExportDictionaryFlowModelDelegate?

    private let fileSharingViewModelFactory: FileSharingViewModelFactory
    
    private let outputFilename: String

    public lazy var fileSharingViewModel: CurrentValueSubject<FileSharingViewModel?, Never> = {
        
        let fileSharingViewModel = fileSharingViewModelFactory.create(
            fileName: self.outputFilename,
            delegate: self
        )
        return .init(fileSharingViewModel)
    } ()

    // MARK: - Initializers

    public init(
        outputFileName: String,
        fileSharingViewModelFactory: FileSharingViewModelFactory,
        delegate: ExportDictionaryFlowModelDelegate
    ) {

        self.outputFilename = outputFileName
        self.fileSharingViewModelFactory = fileSharingViewModelFactory
        self.delegate = delegate
    }
}

// MARK: - Input Methods

extension ExportDictionaryFlowModelImpl: FileSharingViewModelDelegate {
    
    public func fileSharingViewModelDidDispose() {
        
        fileSharingViewModel.value = nil
        delegate?.exportDictionaryFlowModelDidDispose()
    }
}
