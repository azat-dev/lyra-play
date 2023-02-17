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

    private let tempURLProviderFactory: TempURLProviderFactory
    
    // MARK: - Initializers

    public init(
        provideFileForSharingUseCaseFactory: ProvideFileForSharingUseCaseFactory,
        tempURLProviderFactory: TempURLProviderFactory
    ) {
        
        self.provideFileForSharingUseCaseFactory = provideFileForSharingUseCaseFactory
        self.tempURLProviderFactory = tempURLProviderFactory
    }

    // MARK: - Methods

    public func make(
        fileName: String,
        delegate: FileSharingViewModelDelegate
    ) -> FileSharingViewModel {
        
        let tempURLProvider = tempURLProviderFactory.make()

        return FileSharingViewModelImpl(
            fileName: fileName,
            provideFileForSharingUseCaseFactory: provideFileForSharingUseCaseFactory,
            tempURLProvider: tempURLProvider,
            delegate: delegate
        )
    }
}
