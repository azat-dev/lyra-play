//
//  LibraryFlowModelImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 07.09.2022.
//

import Foundation

public final class LibraryFlowModelImplFactory: LibraryFlowModelFactory {

    // MARK: - Properties

    private let viewModelFactory: AudioFilesBrowserViewModelFactory
    private let libraryItemFlowModelFactory: LibraryItemFlowModelFactory
    private let importMediaFilesFlowModelFactory: ImportMediaFilesFlowModelFactory
    
    // MARK: - Initializers

    public init(
        viewModelFactory: AudioFilesBrowserViewModelFactory,
        libraryItemFlowModelFactory: LibraryItemFlowModelFactory,
        importMediaFilesFlowModelFactory: ImportMediaFilesFlowModelFactory
    ) {

        self.viewModelFactory = viewModelFactory
        self.libraryItemFlowModelFactory = libraryItemFlowModelFactory
        self.importMediaFilesFlowModelFactory = importMediaFilesFlowModelFactory
    }

    // MARK: - Methods

    public func create() -> LibraryFlowModel {

        return LibraryFlowModelImpl(
            viewModelFactory: viewModelFactory,
            libraryItemFlowModelFactory: libraryItemFlowModelFactory,
            importMediaFilesFlowModelFactory: importMediaFilesFlowModelFactory
        )
    }
}
