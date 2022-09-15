//
//  DeleteMediaLibraryItemFlowModelImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 15.09.2022.
//

import Foundation

public final class DeleteMediaLibraryItemFlowModelImpl: DeleteMediaLibraryItemFlowModel {

    // MARK: - Properties

    private let itemId: UUID
    private weak var delegate: DeleteMediaLibraryItemFlowDelegate?
    private let editMediaLibraryListUseCaseFactory: EditMediaLibraryListUseCaseFactory

    // MARK: - Initializers

    public init(
        itemId: UUID,
        delegate: DeleteMediaLibraryItemFlowDelegate,
        editMediaLibraryListUseCaseFactory: EditMediaLibraryListUseCaseFactory
    ) {

        self.itemId = itemId
        self.delegate = delegate
        self.editMediaLibraryListUseCaseFactory = editMediaLibraryListUseCaseFactory
        
        Task {
            
            let editMediaLibraryListUseCase = editMediaLibraryListUseCaseFactory.create()
            let result = await editMediaLibraryListUseCase.deleteItem(itemId: itemId)

            guard case .success = result else {
                // TODO: Handle error
                self.delegate?.deleteMediaLibraryItemFlowDidFinish()
                return
            }
            
            self.delegate?.deleteMediaLibraryItemFlowDidFinish()
        }
    }
}

// MARK: - Input Methods

extension DeleteMediaLibraryItemFlowModelImpl {

}

// MARK: - Output Methods

extension DeleteMediaLibraryItemFlowModelImpl {

}
