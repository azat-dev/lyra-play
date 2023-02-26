//
//  PlayMediaWithTranslationsUseCaseStateControllerActiveSession.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 21.02.23.
//

import Foundation

public struct PlayMediaWithTranslationsUseCaseStateControllerActiveSession {
    
    // MARK: - Properties
    
    public let session: PlayMediaWithTranslationsSession
    public let playMediaUseCase: PlayMediaWithSubtitlesUseCase
    public let provideTranslationsToPlayUseCase: ProvideTranslationsToPlayUseCase
    public let pronounceTranslationsUseCase: PronounceTranslationsUseCase
    
    // MARK: - Initializers
    
    public init(
        session: PlayMediaWithTranslationsSession,
        playMediaUseCase: PlayMediaWithSubtitlesUseCase,
        provideTranslationsToPlayUseCase: ProvideTranslationsToPlayUseCase,
        pronounceTranslationsUseCase: PronounceTranslationsUseCase
    ) {
        self.session = session
        self.playMediaUseCase = playMediaUseCase
        self.provideTranslationsToPlayUseCase = provideTranslationsToPlayUseCase
        self.pronounceTranslationsUseCase = pronounceTranslationsUseCase
    }
}
