//
//  InitialPlayMediaWithTranslationsUseCaseStateControllerImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 21.02.2023.
//

import Foundation

public final class InitialPlayMediaWithTranslationsUseCaseStateControllerImplFactory: InitialPlayMediaWithTranslationsUseCaseStateControllerFactory {

    // MARK: - Initializers

    public init() {}

    // MARK: - Methods

    public func make(
        session: PlayMediaWithTranslationsSession,
        delegate: PlayMediaWithTranslationsUseCaseStateControllerDelegate
    ) -> InitialPlayMediaWithTranslationsUseCaseStateController {

        return InitialPlayMediaWithTranslationsUseCaseStateControllerImpl(
            session: session,
            delegate: delegate
        )
    }
}
