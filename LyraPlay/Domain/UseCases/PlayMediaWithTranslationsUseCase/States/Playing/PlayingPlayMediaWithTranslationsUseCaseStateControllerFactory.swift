//
//  PlayingPlayMediaWithTranslationsUseCaseStateControllerFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 22.02.2023.
//

public protocol PlayingPlayMediaWithTranslationsUseCaseStateControllerFactory {

    func make(
        session: PlayMediaWithTranslationsUseCaseStateControllerActiveSession,
        delegate: PlayMediaWithTranslationsUseCaseStateControllerDelegate
    ) -> PlayingPlayMediaWithTranslationsUseCaseStateController
}
