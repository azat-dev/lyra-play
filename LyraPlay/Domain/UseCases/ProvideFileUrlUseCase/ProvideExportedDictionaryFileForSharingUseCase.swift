//
//  ProvideExportedDictionaryFileForSharingUseCase.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 18.01.2023.
//

import Foundation

public final class ProvideExportedDictionaryFileForSharingUseCase: ProvideFileForSharingUseCase {

    // MARK: - Properties
    
    private let exportDictionaryUseCaseFactory: ExportDictionaryUseCaseFactory
    
    // MARK: - Initializers

    public init(
        exportDictionaryUseCaseFactory: ExportDictionaryUseCaseFactory
    ) {
        
        self.exportDictionaryUseCaseFactory = exportDictionaryUseCaseFactory
    }
}

// MARK: - Output Methods

extension ProvideExportedDictionaryFileForSharingUseCase {

    public func provideFile() -> Data? {
        
        let exportDictionaryUseCase = exportDictionaryUseCaseFactory.make()
        
        let exportedDictionaryResult = exportDictionaryUseCase.export()
        
        guard case .success(let exportedDictionary) = exportedDictionaryResult else {
            return nil
        }
        
        let encoder = JSONEncoder()
        return try? encoder.encode(exportedDictionary)
    }
}
