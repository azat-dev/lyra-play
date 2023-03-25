//
//  ProvideTranslationsForSubtitlesUseCase.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 01.09.2022.
//

import Foundation

public protocol ProvideTranslationsForSubtitlesUseCaseInput: AnyObject {

    func prepare(options: AdvancedPlayerSession) async -> Void
}

public protocol ProvideTranslationsForSubtitlesUseCaseOutput: AnyObject {

    func getTranslations(sentenceIndex: Int) async -> [SubtitlesTranslation]
    
    var delegate: ProvideTranslationsForSubtitlesUseCaseDelegate? { get set }
}

public protocol ProvideTranslationsForSubtitlesUseCaseDelegate: AnyObject {
    
    func provideTranslationsForSubtitlesUseCaseDidUpdate()
}

public protocol ProvideTranslationsForSubtitlesUseCase: ProvideTranslationsForSubtitlesUseCaseOutput, ProvideTranslationsForSubtitlesUseCaseInput {

}
