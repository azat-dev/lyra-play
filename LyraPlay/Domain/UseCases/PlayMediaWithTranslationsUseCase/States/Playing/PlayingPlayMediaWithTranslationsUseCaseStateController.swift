//
//  PlayingPlayMediaWithTranslationsUseCaseStateController.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 22.02.2023.
//

import Foundation

public protocol PlayingPlayMediaWithTranslationsUseCaseStateController: PlayMediaWithTranslationsUseCaseStateController {

    func run(
        session: PlayMediaWithTranslationsUseCaseStateControllerActiveSession,
        delegate: PlayMediaWithTranslationsUseCaseStateControllerDelegate
    ) -> Result<Void, PlayMediaWithTranslationsUseCaseError>
}
