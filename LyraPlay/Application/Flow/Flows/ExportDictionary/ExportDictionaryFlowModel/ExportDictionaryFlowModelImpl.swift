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

    private let exportDictionaryUseCaseFactory: ExportDictionaryUseCaseFactory
    private let provideFileForSharingUseCaseFactory: ProvideFileForSharingUseCaseFactory
    private let fileSharingViewModelFactory: FileSharingViewModelFactory

    public lazy var fileSharingViewModel: CurrentValueSubject<FileSharingViewModel?, Never> = {
        
        let fileSharingViewModel = fileSharingViewModelFactory.create(
            fileName: "LyraPlay.dict",
            delegate: self
        )
        return .init(fileSharingViewModel)
    } ()

    // MARK: - Initializers

    public init(
        exportDictionaryUseCaseFactory: ExportDictionaryUseCaseFactory,
        provideFileForSharingUseCaseFactory: ProvideFileForSharingUseCaseFactory,
        fileSharingViewModelFactory: FileSharingViewModelFactory,
        delegate: ExportDictionaryFlowModelDelegate
    ) {

        self.exportDictionaryUseCaseFactory = exportDictionaryUseCaseFactory
        self.provideFileForSharingUseCaseFactory = provideFileForSharingUseCaseFactory
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
