//
//  FileSharingViewModelImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 17.01.2023.
//

import Foundation

public final class FileSharingViewModelImpl: FileSharingViewModel {

    // MARK: - Properties

    private weak var delegate: FileSharingViewModelDelegate?

    private let provideFileForSharingUseCaseFactory: ProvideFileForSharingUseCaseFactory
    
    private let tempURLProvider: TempURLProvider
    
    private let fileName: String

    // MARK: - Initializers

    public init(
        fileName: String,
        provideFileForSharingUseCaseFactory: ProvideFileForSharingUseCaseFactory,
        tempURLProvider: TempURLProvider,
        delegate: FileSharingViewModelDelegate
    ) {

        self.fileName = fileName
        self.provideFileForSharingUseCaseFactory = provideFileForSharingUseCaseFactory
        self.tempURLProvider = tempURLProvider
        self.delegate = delegate
    }
}

// MARK: - Input Methods

extension FileSharingViewModelImpl {

    public func dispose() {

        delegate?.fileSharingViewModelDidDispose()
    }
}

// MARK: - Output Methods

extension FileSharingViewModelImpl {

    public func prepareFileURL() -> URL? {

        return tempURLProvider.provide(for: fileName)
    }
    
    public func putFile(at url: URL) {
        
        let provideFileForSharingUseCase = provideFileForSharingUseCaseFactory.make()
        let data = provideFileForSharingUseCase.provideFile()
        
        try? data?.write(to: url, options: .atomic)
    }
}
