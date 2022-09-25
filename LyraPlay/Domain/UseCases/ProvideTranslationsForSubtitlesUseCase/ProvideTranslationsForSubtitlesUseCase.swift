//
//  ProvideTranslationsForSubtitlesUseCase.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 01.09.2022.
//

import Foundation

public protocol ProvideTranslationsForSubtitlesUseCaseInput {

    func prepare(options: AdvancedPlayerSession) async -> Void
}

public protocol ProvideTranslationsForSubtitlesUseCaseOutput {

    func getTranslations(sentenceIndex: Int) async -> [SubtitlesTranslation]
}

public protocol ProvideTranslationsForSubtitlesUseCase: ProvideTranslationsForSubtitlesUseCaseOutput, ProvideTranslationsForSubtitlesUseCaseInput {

}