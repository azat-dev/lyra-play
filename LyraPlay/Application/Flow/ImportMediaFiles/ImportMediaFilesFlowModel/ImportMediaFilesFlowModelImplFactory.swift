//
//  ImportMediaFilesFlowModelImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 10.09.2022.
//

import Foundation

public final class ImportMediaFilesFlowModelImplFactory: ImportMediaFilesFlowModelFactory {

    // MARK: - Properties

    private let delegate: ImportMediaFilesFlowModel
    private let filesPickerViewModelFactory: FilesPickerViewModelFactory
    private let importAudioFileUseCaseFactory: ImportAudioFileUseCaseFactory

    // MARK: - Initializers

    public init(
        delegate: ImportMediaFilesFlowModel,
        filesPickerViewModelFactory: FilesPickerViewModelFactory,
        importAudioFileUseCaseFactory: ImportAudioFileUseCaseFactory
    ) {

        self.delegate = delegate
        self.filesPickerViewModelFactory = filesPickerViewModelFactory
        self.importAudioFileUseCaseFactory = importAudioFileUseCaseFactory
    }

    // MARK: - Methods

    public func create(
        allowedDocumentTypes: [String],
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
