//
//  DeleteDictionaryItemFlowModelImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 13.09.2022.
//

import Foundation

public final class DeleteDictionaryItemFlowModelImpl: DeleteDictionaryItemFlowModel {

    // MARK: - Properties

    private let itemId: UUID
    private weak var delegate: DeleteDictionaryItemFlowDelegate?
    private let editDictionaryListUseCaseFactory: EditDictionaryListUseCaseFactory

    // MARK: - Initializers

    public init(
        itemId: UUID,
        delegate: DeleteDictionaryItemFlowDelegate,
        editDictionaryListUseCaseFactory: EditDictionaryListUseCaseFactory
    ) {

        self.itemId = itemId
        self.delegate = delegate
        self.editDictionaryListUseCaseFactory = editDictionaryListUseCaseFactory
        
        
        Task {
            
            let editDictionaryListUseCase = editDictionaryListUseCaseFactory.make()
            let result = await editDictionaryListUseCase.deleteItem(itemId: itemId)
            
            guard case .success = result else {
                
                self.delegate?.deleteDictionaryItemFlowDidFail()
                return
            }
            
            self.delegate?.deleteDictionaryItemFlowDidFinish(deleteIds: [itemId])
        }
    }
}

// MARK: - Input Methods

extension DeleteDictionaryItemFlowModelImpl {

}

// MARK: - Output Methods

extension DeleteDictionaryItemFlowModelImpl {

}
