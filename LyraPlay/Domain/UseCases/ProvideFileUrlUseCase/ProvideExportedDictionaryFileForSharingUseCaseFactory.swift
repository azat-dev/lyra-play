//
//  ProvideExportedDictionaryFileForSharingUseCaseFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 18.01.2023.
//

import Foundation

public final class ProvideExportedDictionaryFileForSharingUseCaseFactory: ProvideFileForSharingUseCaseFactory {

    // MARK: - Properties
    
    private let exportDictionaryUseCaseFactory: ExportDictionaryUseCaseFactory
    
    // MARK: - Initializers

    public init(exportDictionaryUseCaseFactory: ExportDictionaryUseCaseFactory) {
        
        self.exportDictionaryUseCaseFactory = exportDictionaryUseCaseFactory
    }

    // MARK: - Methods

    public func make() -> ProvideFileForSharingUseCase {

        return ProvideExportedDictionaryFileForSharingUseCase(exportDictionaryUseCaseFactory: exportDictionaryUseCaseFactory)
    }
}
