//
//  ImportAudioFileUseCaseFileNameGenerator.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.09.22.
//

import Foundation

// MARK: - Interfaces

public protocol ImportAudioFileUseCaseFileNameGenerator {
    
    func generate(originalName: String) -> String
}

// MARK: - Implementations

public class ImportAudioFileUseCaseFileNameGeneratorImpl: ImportAudioFileUseCaseFileNameGenerator {
    
    // MARK: - Initializers
    
    public init() {}
    
    // MARK: - Methods
    
    public func generate(originalName: String) -> String {
        
        let audioFileId = UUID().uuidString
        let fileExtension = URL(fileURLWithPath: originalName).pathExtension
        return "\(audioFileId).\(fileExtension)"
    }
}
