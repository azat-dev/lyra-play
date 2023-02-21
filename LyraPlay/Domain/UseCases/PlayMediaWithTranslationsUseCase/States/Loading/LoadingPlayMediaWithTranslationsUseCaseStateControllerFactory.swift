//
//  LoadingPlayMediaWithTranslationsUseCaseStateControllerFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 21.02.2023.
//

public protocol LoadingPlayMediaWithTranslationsUseCaseStateControllerFactory {

    func make(
        session: PlayMediaWithTranslationsSession,
        delegate: PlayMediaWithTranslationsUseCaseStateControllerDelegate
    ) -> LoadingPlayMediaWithTranslationsUseCaseStateController
}
