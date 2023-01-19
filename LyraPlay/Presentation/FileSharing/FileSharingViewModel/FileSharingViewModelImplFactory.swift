//
//  FileSharingViewModelImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 18.01.2023.
//

import Foundation

public final class FileSharingViewModelImplFactory: FileSharingViewModelFactory {

    // MARK: - Properties

    private let provideFileForSharingUseCaseFactory: ProvideFileForSharingUseCaseFactory

    private let tempURLProvider: TempURLProvider
    
    // MARK: - Initializers

    public init(
        provideFileForSharingUseCaseFactory: ProvideFileForSharingUseCaseFactory,
        tempURLProvider: TempURLProvider
    ) {
        
        self.provideFileForSharingUseCaseFactory = provideFileForSharingUseCaseFactory
        self.tempURLProvider = tempURLProvider
    }

    // MARK: - Methods

    public func create(
        fileName: String,
        delegate: FileSharingViewModelDelegate
    ) -> FileSharingViewModel {

        return FileSharingViewModelImpl(
            fileName: fileName,
            provideFileForSharingUseCaseFactory: provideFileForSharingUseCaseFactory,
            tempURLProvider: tempURLProvider,
            delegate: delegate
        )
    }
}
