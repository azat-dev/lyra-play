//
//  TempURLProviderImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.01.23.
//

import Foundation

public class TempURLProviderImpl: TempURLProvider {
    
    // MARK: - Properties
    
    private let fileManager: FileManager
    
    // MARK: - Initializers
    
    public init(fileManager: FileManager) {
        
        self.fileManager = fileManager
    }
    
    // MARK: - Methods
    
    public func provide(for fileName: String) -> URL {
    
        return fileManager.temporaryDirectory.appendingPathComponent(fileName, isDirectory: false)
    }
}
