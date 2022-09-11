//
//  ImportMediaFilesFlowModelImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 10.09.2022.
//

import Foundation

public final class ImportMediaFilesFlowModelImplFactory: ImportMediaFilesFlowModelFactory {

    // MARK: - Properties

    private let allowedDocumentTypes: [String]
    private let filesPickerViewModelFactory: FilesPickerViewModelFactory
    private let importAudioFileUseCaseFactory: ImportAudioFileUseCaseFactory

    // MARK: - Initializers

    public init(
        allowedDocumentTypes: [String],
        filesPickerViewModelFactory: FilesPickerViewModelFactory,
        importAudioFileUseCaseFactory: ImportAudioFileUseCaseFactory
    ) {

        self.allowedDocumentTypes = allowedDocumentTypes
        self.filesPickerViewModelFactory = filesPickerViewModelFactory
        self.importAudioFileUseCaseFactory = importAudioFileUseCaseFactory
    }

    // MARK: - Methods

    public func create(
        delegate: ImportMediaFilesFlowModelDelegate
    ) -> ImportMediaFilesFlowModel {

        return ImportMediaFilesFlowModelImpl(
            allowedDocumentTypes: allowedDocumentTypes,
            delegate: delegate,
            filesPickerViewModelFactory: filesPickerViewModelFactory,
            importAudioFileUseCaseFactory: importAudioFileUseCaseFactory
        )
    }
}