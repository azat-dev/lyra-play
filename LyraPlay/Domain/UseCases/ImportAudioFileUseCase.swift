//
//  ImportAudioFileUseCase.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 24.06.22.
//

import Foundation

// MARK: - Interfaces

enum ImportAudioFileUseCaseError: Error {
    case wrongFormat
    case internalError(Error)
}

protocol ImportAudioFileUseCase {
    
    func importFile(data: Data) async -> Result<AudioFileInfo, ImportAudioFileUseCaseError>
}

// MARK: - Implementations
