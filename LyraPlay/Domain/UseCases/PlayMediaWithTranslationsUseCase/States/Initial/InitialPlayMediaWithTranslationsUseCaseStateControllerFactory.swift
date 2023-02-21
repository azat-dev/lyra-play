//
//  InitialPlayMediaWithTranslationsUseCaseStateControllerFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 21.02.2023.
//

public protocol InitialPlayMediaWithTranslationsUseCaseStateControllerFactory {

    func make(
        session: PlayMediaWithTranslationsSession,
        delegate: PlayMediaWithTranslationsUseCaseStateControllerDelegate
    ) -> InitialPlayMediaWithTranslationsUseCaseStateController
}
