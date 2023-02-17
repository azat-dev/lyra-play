//
//  TextToSpeechConverterImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 01.09.2022.
//

import Foundation

public final class TextToSpeechConverterImplFactory: TextToSpeechConverterFactory {

    // MARK: - Initializers

    public init() {

    }

    // MARK: - Methods

    public func make() -> TextToSpeechConverter {

        return TextToSpeechConverterImpl()
    }
}
