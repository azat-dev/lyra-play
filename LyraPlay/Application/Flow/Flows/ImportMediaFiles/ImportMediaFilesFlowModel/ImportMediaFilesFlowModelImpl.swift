//
//  ImportMediaFilesFlowModelImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 10.09.2022.
//

import Foundation
import Combine

public final class ImportMediaFilesFlowModelImpl: ImportMediaFilesFlowModel {

    // MARK: - Properties

    private let allowedDocumentTypes: [String]
    private weak var delegate: ImportMediaFilesFlowModelDelegate?
    
    private let filesPickerViewModelFactory: FilesPickerViewModelFactory
    private let importAudioFileUseCaseFactory: ImportAudioFileUseCaseFactory
    
    public var filesPickerViewModel = CurrentValueSubject<FilesPickerViewModel?, Never>(nil)
    
    // MARK: - Initializers

    public init(
        allowedDocumentTypes: [String],
        delegate: ImportMediaFilesFlowModelDelegate,
        filesPickerViewModelFactory: FilesPickerViewModelFactory,
        importAudioFileUseCaseFactory: ImportAudioFileUseCaseFactory
    ) {

        self.allowedDocumentTypes = allowedDocumentTypes
        self.delegate = delegate
        self.filesPickerViewModelFactory = filesPickerViewModelFactory
        self.importAudioFileUseCaseFactory = importAudioFileUseCaseFactory
        
        self.filesPickerViewModel.value = filesPickerViewModelFactory.create(
            documentTypes: allowedDocumentTypes,
            allowsMultipleSelection: true,
            delegate: self
        )
    }
}

// MARK: - Input Methods

extension ImportMediaFilesFlowModelImpl {

}

// MARK: - FilesPickerViewModelDelegate

extension ImportMediaFilesFlowModelImpl: FilesPickerViewModelDelegate {
    
    public func filesPickerDidCancel() {
        
        filesPickerViewModel.value = nil
        delegate?.importMediaFilesFlowDidFinish()
    }

    public func filesPickerDidFinish() {
        
        filesPickerViewModel.value = nil
        delegate?.importMediaFilesFlowDidFinish()
    }
    
    private func importAudioFiles(urls: [URL]) async {
        
        let importFileUseCase = importAudioFileUseCaseFactory.create()
        
        let numberOfFiles = urls.count
        
        for index in 0..<numberOfFiles {
            
            let url = urls[index]
            url.startAccessingSecurityScopedResource()
            
            guard let data = try? Data(contentsOf: url) else {
                continue
            }
            
            let _ = await importFileUseCase.importFile(
                originalFileName: url.lastPathComponent,
                fileData: data
            )
            
            delegate?.importMediaFilesFlowProgress(totalFilesCount: numberOfFiles, importedFilesCount: index + 1)
        }
        
        filesPickerViewModel.value = nil
        delegate?.importMediaFilesFlowDidFinish()
    }
    
    public func filesPickerDidChoose(urls: [URL]) {
        
        Task {
            await self.importAudioFiles(urls: urls)
        }
    }
}
