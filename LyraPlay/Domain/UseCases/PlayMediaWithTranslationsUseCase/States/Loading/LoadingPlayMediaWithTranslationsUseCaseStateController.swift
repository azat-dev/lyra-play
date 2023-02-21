//
//  LoadingPlayMediaWithTranslationsUseCaseStateController.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 21.02.2023.
//

import Foundation

public protocol LoadingPlayMediaWithTranslationsUseCaseStateController: PlayMediaWithTranslationsUseCaseStateController {

    func load(session: PlayMediaWithTranslationsSession) async -> Result<Void, PlayMediaWithTranslationsUseCaseError>
}
