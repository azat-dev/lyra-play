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
    private let provideFileUrlUseCaseFactory: ProvideFileUrlUseCaseFactory
    private let fileSharingViewModelFactory: FileSharingViewModelFactory

    public lazy var fileSharingViewModel: CurrentValueSubject<FileSharingViewModel?, Never> = {
        
        let fileSharingViewModel = fileSharingViewModelFactory.create(delegate: self)
        return .init(fileSharingViewModel)
    } ()

    // MARK: - Initializers

    public init(
        exportDictionaryUseCaseFactory: ExportDictionaryUseCaseFactory,
        provideFileUrlUseCaseFactory: ProvideFileUrlUseCaseFactory,
        fileSharingViewModelFactory: FileSharingViewModelFactory,
        delegate: ExportDictionaryFlowModelDelegate
    ) {

        self.exportDictionaryUseCaseFactory = exportDictionaryUseCaseFactory
        self.provideFileUrlUseCaseFactory = provideFileUrlUseCaseFactory
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
