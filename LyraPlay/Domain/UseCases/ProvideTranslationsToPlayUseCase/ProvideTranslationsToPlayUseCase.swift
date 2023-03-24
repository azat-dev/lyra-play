//
//  ProvideTranslationsToPlayUseCase.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 01.09.2022.
//

import Foundation

public enum TranslationsToPlayData: Equatable {

    case single(translation: SubtitlesTranslationItem)
    
    case groupAfterSentence(items: [SubtitlesTranslationItem])
}

public protocol ProvideTranslationsToPlayUseCaseInput: AnyObject {

    func prepare(params: AdvancedPlayerSession) async -> Void
}

public protocol ProvideTranslationsToPlayUseCaseOutput: AnyObject {

    func getTranslationsToPlay(for position: SubtitlesPosition) -> TranslationsToPlayData?
}

public protocol ProvideTranslationsToPlayUseCase: ProvideTranslationsToPlayUseCaseOutput, ProvideTranslationsToPlayUseCaseInput {}
