//
//  ImportDictionaryArchiveUseCase.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 21.01.2023.
//

import Foundation

public enum ImportDictionaryArchiveUseCaseError: Error {

    case wrongDataFormat
    case internalError(Error?)
}

public protocol ImportDictionaryArchiveUseCaseInput: AnyObject {

}

public protocol ImportDictionaryArchiveUseCaseOutput: AnyObject {

}

public protocol ImportDictionaryArchiveUseCase: ImportDictionaryArchiveUseCaseOutput, ImportDictionaryArchiveUseCaseInput {

    func importArchive(data: Data) async -> Result<Void, ImportDictionaryArchiveUseCaseError>
}
