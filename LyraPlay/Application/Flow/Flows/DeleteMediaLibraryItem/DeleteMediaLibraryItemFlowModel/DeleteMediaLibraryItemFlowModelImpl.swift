//
//  DeleteMediaLibraryItemFlowModelImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 15.09.2022.
//

import Foundation
import Combine

public final class DeleteMediaLibraryItemFlowModelImpl: DeleteMediaLibraryItemFlowModel {
    
    // MARK: - Properties
    
    private let itemId: UUID
    private weak var delegate: DeleteMediaLibraryItemFlowDelegate?
    private let editMediaLibraryListUseCaseFactory: EditMediaLibraryListUseCaseFactory
    
    public var confirmDialogViewModel = CurrentValueSubject<ConfirmDialogViewModel?, Never>(nil)
    
    // MARK: - Initializers
    
    public init(
        itemId: UUID,
        delegate: DeleteMediaLibraryItemFlowDelegate,
        editMediaLibraryListUseCaseFactory: EditMediaLibraryListUseCaseFactory,
        confirmDialogViewModelFactory: ConfirmDialogViewModelFactory
    ) {
        
        self.itemId = itemId
        self.delegate = delegate
        self.editMediaLibraryListUseCaseFactory = editMediaLibraryListUseCaseFactory
        
        self.confirmDialogViewModel.value = confirmDialogViewModelFactory.create(
            messageText: "Do you want to delete library item?",
            confirmText: "Delete",
            cancelText: "Cancel",
            isDestructive: true,
            delegate: self
        )
    }
}

// MARK: - Input Methods

extension DeleteMediaLibraryItemFlowModelImpl: ConfirmDialogViewModelDelegate {
    
    private func delete() async {
        
        let editMediaLibraryListUseCase = editMediaLibraryListUseCaseFactory.create()
        let result = await editMediaLibraryListUseCase.deleteItem(id: itemId)
        
        guard case .success = result else {
            // TODO: Handle error
            self.delegate?.deleteMediaLibraryItemFlowDidFinish()
            return
        }
        
        self.delegate?.deleteMediaLibraryItemFlowDidFinish()
    }
    
    public func confirmDialogDidCancel() {
        
        confirmDialogViewModel.value = nil
        delegate?.deleteMediaLibraryItemFlowDidCancel()
    }
    
    public func confirmDialogDidConfirm() {
        
        confirmDialogViewModel.value = nil
        
        Task {
            await self.delete()
        }
    }
    
    public func confirmDialogDispose() {
        
        confirmDialogViewModel.value = nil
        delegate?.deleteMediaLibraryItemFlowDidDispose()
    }
}
