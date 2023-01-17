//
//  ExportDictionaryUseCase.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 17.01.2023.
//

import Foundation

public enum ExportDictionaryUseCaseError: Error {

    case internalError
}

public protocol ExportDictionaryUseCaseInput: AnyObject {

}

public protocol ExportDictionaryUseCaseOutput: AnyObject {

    func export() async -> Result<[ExportedDictionaryItem], ExportDictionaryUseCaseError>
}

public protocol ExportDictionaryUseCase: ExportDictionaryUseCaseOutput, ExportDictionaryUseCaseInput {

}