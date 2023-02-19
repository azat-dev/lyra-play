//
//  PlayMediaWithSubtitlesUseStateControllerContext.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 16.02.23.
//

import Foundation

public struct PlayMediaWithSubtitlesUseStateControllerActiveSession {
    
    public let params: PlayMediaWithSubtitlesSessionParams
    public let playMediaUseCase: PlayMediaUseCase
    public let playSubtitlesUseCase: PlaySubtitlesUseCase?
    
    public init(
        params: PlayMediaWithSubtitlesSessionParams,
        playMediaUseCase: PlayMediaUseCase,
        playSubtitlesUseCase: PlaySubtitlesUseCase? = nil
    ) {
        self.params = params
        self.playMediaUseCase = playMediaUseCase
        self.playSubtitlesUseCase = playSubtitlesUseCase
    }
    
}

public protocol PlayMediaWithSubtitlesUseStateControllerDelegate: AnyObject {
    
    func load(params: PlayMediaWithSubtitlesSessionParams) async -> Result<Void, PlayMediaWithSubtitlesUseCaseError>
    
    func didLoad(session: PlayMediaWithSubtitlesUseStateControllerActiveSession)
    
    func didFailLoad(params: PlayMediaWithSubtitlesSessionParams)
    
    func didFinish(session: PlayMediaWithSubtitlesUseStateControllerActiveSession)
    
    func pause(session: PlayMediaWithSubtitlesUseStateControllerActiveSession) -> Result<Void, PlayMediaWithSubtitlesUseCaseError>
    
    func didPause(session: PlayMediaWithSubtitlesUseStateControllerActiveSession)
    
    func play(session: PlayMediaWithSubtitlesUseStateControllerActiveSession) -> Result<Void, PlayMediaWithSubtitlesUseCaseError>
    
    func didStartPlay(session: PlayMediaWithSubtitlesUseStateControllerActiveSession)
    
    func stop(session: PlayMediaWithSubtitlesUseStateControllerActiveSession) -> Result<Void, PlayMediaWithSubtitlesUseCaseError>
    
    func didStop()
}
