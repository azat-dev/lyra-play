//
//  TempURLProviderImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.01.23.
//

import Foundation

public class TempURLProviderImplFactory: TempURLProviderFactory {
    
    // MARK: - Properties
    
    private let fileManager: FileManager
    
    // MARK: - Initializers
    
    public init(fileManager: FileManager) {
        
        self.fileManager = fileManager
    }
    
    // MARK: - Methods
    
    public func create() -> TempURLProvider {
        
        return TempURLProviderImpl(fileManager: fileManager)
    }
}
