//
//  ImportAudioFileUseCase.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 30.08.2022.
//

import Foundation

public enum ImportAudioFileUseCaseError: Error {

    case wrongFormat
    case internalError(Error?)
}

public protocol ImportAudioFileUseCaseInput {}

public protocol ImportAudioFileUseCaseOutput {

    func importFile(
        originalFileName: String,
        fileData: Data
    ) async -> Result<AudioFileInfo, ImportAudioFileUseCaseError>
}

public protocol ImportAudioFileUseCase: ImportAudioFileUseCaseOutput, ImportAudioFileUseCaseInput {}