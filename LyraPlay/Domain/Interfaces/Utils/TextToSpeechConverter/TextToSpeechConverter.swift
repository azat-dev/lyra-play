//
//  TextToSpeechConverter.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 01.09.2022.
//

import Foundation

public enum TextToSpeechConverterError: Error {
    
    case internalError(Error?)
}

public protocol TextToSpeechConverterOutput {
    
    func convert(text: String, language: String) async -> Result<Data, TextToSpeechConverterError>
}

public protocol TextToSpeechConverter: TextToSpeechConverterOutput {}
