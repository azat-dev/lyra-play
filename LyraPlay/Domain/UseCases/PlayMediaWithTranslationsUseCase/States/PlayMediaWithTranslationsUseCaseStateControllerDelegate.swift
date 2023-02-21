//
//  PlayMediaWithTranslationsUseCaseStateControllerDelegate.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 21.02.23.
//

import Foundation

public protocol PlayMediaWithTranslationsUseCaseStateControllerDelegate: AnyObject {
    
    func load(session: PlayMediaWithTranslationsSession) async -> Result<Void, PlayMediaWithTranslationsUseCaseError>
    
    func didLoad(session: PlayMediaWithTranslationsUseCaseStateControllerActiveSession)
    
    func didFailLoad(session: PlayMediaWithTranslationsSession)
    
    func play(
        session: PlayMediaWithTranslationsUseCaseStateControllerActiveSession,
        delegate: PlayMediaWithTranslationsUseCaseStateControllerDelegate
    ) -> Result<Void, PlayMediaWithTranslationsUseCaseError>
}