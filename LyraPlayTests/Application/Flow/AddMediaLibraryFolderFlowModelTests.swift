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
        targetFolderId: UUID?Mock,
        delegate: AddMediaLibraryFolderFlowModelDelegateMock,
        browseMediaLibraryUseCaseFactory: BrowseMediaLibraryUseCaseFactoryMock,
        PromptDialogViewModelFactory: PromptDialogViewModelFactoryMock
    )

    // MARK: - Methods

    func createSUT() -> SUT {

        let targetFolderId = mock(UUID?.self)

        let delegate = mock(AddMediaLibraryFolderFlowModelDelegate.self)

        let browseMediaLibraryUseCaseFactory = mock(BrowseMediaLibraryUseCaseFactory.self)

        let PromptDialogViewModelFactory = mock(PromptDialogViewModelFactory.self)

        let flowModel = AddMediaLibraryFolderFlowModelImpl(
            targetFolderId: targetFolderId,
            delegate: delegate,
            browseMediaLibraryUseCaseFactory: browseMediaLibraryUseCaseFactory,
            PromptDialogViewModelFactory: PromptDialogViewModelFactory
        )

        detectMemoryLeak(instance: flowModel)

        return (
            flowModel: flowModel,
            targetFolderId: targetFolderId,
            delegate: delegate,
            browseMediaLibraryUseCaseFactory: browseMediaLibraryUseCaseFactory,
            PromptDialogViewModelFactory: PromptDialogViewModelFactory
        )
    }
}