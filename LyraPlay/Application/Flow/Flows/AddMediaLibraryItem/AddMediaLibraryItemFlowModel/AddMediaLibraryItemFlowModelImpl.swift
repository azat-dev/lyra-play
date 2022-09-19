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

    public let chooseItemTypeViewModel = CurrentValueSubject<ChooseDialogViewModel?, Never>(nil)
    public let importMediaFilesFlow = CurrentValueSubject<ImportMediaFilesFlowModel?, Never>(nil)
    
    // MARK: - Initializers

    public init(
        targetFolderId: UUID?,
        delegate: AddMediaLibraryItemFlowModelDelegate,
        chooseDialogViewModelFactory: ChooseDialogViewModelFactory,
        importMediaFilesFlowModelFactory: ImportMediaFilesFlowModelFactory
    ) {

        self.targetFolderId = targetFolderId
        self.delegate = delegate
        self.chooseDialogViewModelFactory = chooseDialogViewModelFactory
        self.importMediaFilesFlowModelFactory = importMediaFilesFlowModelFactory
        
        showChooseTypeDialog()
    }
    
    private func showChooseTypeDialog() {
        
        let viewModel = chooseDialogViewModelFactory.create(
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

// MARK: - ChooseDialogViewModelDelegate

extension AddMediaLibraryItemFlowModelImpl: ChooseDialogViewModelDelegate {

    public func chooseDialogViewModelDidDispose() {

        chooseItemTypeViewModel.value = nil
    }
    
    public func chooseDialogViewModelDidCancel() {
        
        chooseItemTypeViewModel.value = nil
        delegate?.addMediaLibraryItemFlowModelDidCancel()
    }
    
    private func createFolder() {
        
        delegate?.addMediaLibraryItemFlowModelDidFinish()
    }
    
    private func runImportMediaFilesFlow() {
        
        let importMediaFilesFlow = importMediaFilesFlowModelFactory.create(
            targetFolderId: targetFolderId,
            delegate: self
        )
        
        self.importMediaFilesFlow.value = importMediaFilesFlow
    }
    
    public func chooseDialogViewModelDidChoose(itemId: String) {
 
        chooseItemTypeViewModel.value = nil
        
        switch Variants(rawValue: itemId) {
        
        case .createFolder:
            createFolder()
            
        case .importMediaFiles:
            runImportMediaFilesFlow()
            
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
