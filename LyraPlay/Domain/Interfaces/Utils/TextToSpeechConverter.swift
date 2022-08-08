//
//  TextToSpeechConverter.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 08.08.2022.
//

import Foundation

// MARK: - Interfaces

public enum TextToSpeechConverterError: Error {

    case internalError(Error?)
}

public protocol TextToSpeechConverter {

    func convert(text: String, language: String) async -> Result<Data, TextToSpeechConverterError>
}
