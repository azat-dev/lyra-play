//
//  AddMediaLibraryFolderFlowModelTests.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.09.2022.
//

import Foundation
import XCTest
import Mockingbird
import LyraPlay

class AddMediaLibraryFolderFlowModelTests: XCTestCase {

    typealias SUT = (
        flowModel: AddMediaLibraryFolderFlowModel,
        delegate: AddMediaLibraryFolderFlowModelDelegateMock,
        browseMediaLibraryUseCaseFactory: BrowseMediaLibraryUseCaseFactoryMock,
        PromptDialogViewModelFactory: PromptDialogViewModelFactoryMock
    )

    // MARK: - Methods

    func createSUT(targetFolderId: UUID?) -> SUT {

        let delegate = mock(AddMediaLibraryFolderFlowModelDelegate.self)

        let browseMediaLibraryUseCaseFactory = mock(BrowseMediaLibraryUseCaseFactory.self)

        let PromptDialogViewModelFactory = mock(PromptDialogViewModelFactory.self)

        let flowModel = AddMediaLibraryFolderFlowModelImpl(
            targetFolderId: targetFolderId,
            delegate: delegate,
            browseMediaLibraryUseCaseFactory: browseMediaLibraryUseCaseFactory,
            promptDialogViewModelFactory: PromptDialogViewModelFactory
        )

        detectMemoryLeak(instance: flowModel)

        return (
            flowModel: flowModel,
            delegate: delegate,
            browseMediaLibraryUseCaseFactory: browseMediaLibraryUseCaseFactory,
            PromptDialogViewModelFactory: PromptDialogViewModelFactory
        )
    }
}
