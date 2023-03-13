//
//  AddMediaLibraryItemFlowModelImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.09.2022.
//

import Foundation
import Combine

public final class AddMediaLibraryItemFlowModelImpl: AddMediaLibraryItemFlowModel {

    private enum Variants: String {
        
        case createFolder
        case importMediaFiles
    }
    
    // MARK: - Properties

    private let targetFolderId: UUID?
    private weak var delegate: AddMediaLibraryItemFlowModelDelegate? 

    private let chooseDialogViewModelFactory: ChooseDialogViewModelFactory
    private let importMediaFilesFlowModelFactory: ImportMediaFilesFlowModelFactory
    private let addMediaLibraryFolderFlowModelFactory: AddMediaLibraryFolderFlowModelFactory

    public let chooseItemTypeViewModel = CurrentValueSubject<ChooseDialogViewModel?, Never>(nil)
    public let importMediaFilesFlow = CurrentValueSubject<ImportMediaFilesFlowModel?, Never>(nil)
    public let addMediaLibraryFolderFlow = CurrentValueSubject<AddMediaLibraryFolderFlowModel?, Never>(nil)
    
    // MARK: - Initializers

    public init(
        targetFolderId: UUID?,
        fileUrl: URL?,
        delegate: AddMediaLibraryItemFlowModelDelegate,
        chooseDialogViewModelFactory: ChooseDialogViewModelFactory,
        importMediaFilesFlowModelFactory: ImportMediaFilesFlowModelFactory,
        addMediaLibraryFolderFlowModelFactory: AddMediaLibraryFolderFlowModelFactory
    ) {

        self.targetFolderId = targetFolderId
        self.delegate = delegate
        self.chooseDialogViewModelFactory = chooseDialogViewModelFactory
        self.importMediaFilesFlowModelFactory = importMediaFilesFlowModelFactory
        self.addMediaLibraryFolderFlowModelFactory = addMediaLibraryFolderFlowModelFactory
        
        guard let fileUrl = fileUrl else {
            showChooseTypeDialog()
            return
        }
        
        runImportMediaFilesFlow(fileUrl: fileUrl)
    }
    
    private func showChooseTypeDialog() {
        
        let viewModel = chooseDialogViewModelFactory.make(
            title: "Add library item",
            items: [
                .init(id: Variants.importMediaFiles.rawValue, title: "Import Files"),
                .init(id: Variants.createFolder.rawValue, title: "Create Folder"),
            ],
            delegate: self
        )
        
        chooseItemTypeViewModel.value = viewModel
    }
}

// MARK: - AddMediaLibraryFolderFlowModelDelegate

extension AddMediaLibraryItemFlowModelImpl: AddMediaLibraryFolderFlowModelDelegate {
    
    public func addMediaLibraryFolderFlowModelDidDispose() {
        
        addMediaLibraryFolderFlow.value = nil
    }
    
    public func addMediaLibraryFolderFlowModelCancel() {
        
        addMediaLibraryFolderFlow.value = nil
        delegate?.addMediaLibraryItemFlowModelDidCancel()
    }
    
    public func addMediaLibraryFolderFlowModelDidCreate() {
        
        addMediaLibraryFolderFlow.value = nil
        delegate?.addMediaLibraryItemFlowModelDidFinish()
    }
}

// MARK: - ChooseDialogViewModelDelegate

extension AddMediaLibraryItemFlowModelImpl: ChooseDialogViewModelDelegate {

    public func chooseDialogViewModelDidDispose() {

        chooseItemTypeViewModel.value = nil
    }
    
    public func chooseDialogViewModelDidCancel() {
        
        chooseItemTypeViewModel.value = nil
        delegate?.addMediaLibraryItemFlowModelDidCancel()
    }
    
    private func runAddMediaLibraryFolderFlow() {
        
        guard self.addMediaLibraryFolderFlow.value == nil else {
            return
        }
        
        let addMediaLibraryFolderFlow = addMediaLibraryFolderFlowModelFactory.make(
            targetFolderId: targetFolderId,
            delegate: self
        )
        
        self.addMediaLibraryFolderFlow.value = addMediaLibraryFolderFlow
    }
    
    private func runImportMediaFilesFlow(fileUrl: URL?) {
    
        guard self.importMediaFilesFlow.value == nil else {
            return
        }
        
        let importMediaFilesFlow = importMediaFilesFlowModelFactory.make(
            targetFolderId: targetFolderId,
            fileUrl: fileUrl,
            delegate: self
        )
        
        self.importMediaFilesFlow.value = importMediaFilesFlow
    }
    
    public func chooseDialogViewModelDidChoose(itemId: String) {
 
        chooseItemTypeViewModel.value = nil
        
        switch Variants(rawValue: itemId) {
        
        case .createFolder:
            runAddMediaLibraryFolderFlow()
            
        case .importMediaFiles:
            runImportMediaFilesFlow(fileUrl: nil)
            
        default:
            fatalError("Not implemented")
        }
    }
}

// MARK: - ImportMediaFilesFlowModelDelegate

extension AddMediaLibraryItemFlowModelImpl: ImportMediaFilesFlowModelDelegate {

    public func importMediaFilesFlowDidFinish() {
        
        importMediaFilesFlow.value = nil
        delegate?.addMediaLibraryItemFlowModelDidFinish()
    }
    
    public func importMediaFilesFlowProgress(totalFilesCount: Int, importedFilesCount: Int) {
    }
    
    public func importMediaFilesFlowDidDispose() {
        
        importMediaFilesFlow.value = nil
    }
}
