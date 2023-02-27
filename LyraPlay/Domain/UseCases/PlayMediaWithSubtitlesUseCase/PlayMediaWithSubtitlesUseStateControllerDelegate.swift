//
//  PlayMediaWithSubtitlesUseStateControllerContext.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 16.02.23.
//

import Foundation
import Combine

public struct PlayMediaWithSubtitlesUseStateControllerActiveSession {
    
    public let params: PlayMediaWithSubtitlesSessionParams
    public let playMediaUseCase: PlayMediaUseCase
    public let playSubtitlesUseCase: PlaySubtitlesUseCase?
    public let subtitlesState: CurrentValueSubject<SubtitlesState?, Never>
    
    public init(
        params: PlayMediaWithSubtitlesSessionParams,
        playMediaUseCase: PlayMediaUseCase,
        playSubtitlesUseCase: PlaySubtitlesUseCase? = nil,
        subtitlesState: CurrentValueSubject<SubtitlesState?, Never>
    ) {
        self.params = params
        self.playMediaUseCase = playMediaUseCase
        self.playSubtitlesUseCase = playSubtitlesUseCase
        self.subtitlesState = subtitlesState
    }
    
}

public protocol PlayMediaWithSubtitlesUseStateControllerDelegate: AnyObject {
    
    func load(params: PlayMediaWithSubtitlesSessionParams) async -> Result<Void, PlayMediaWithSubtitlesUseCaseError>
    
    func didLoad(session: PlayMediaWithSubtitlesUseStateControllerActiveSession)
    
    func didFailLoad(params: PlayMediaWithSubtitlesSessionParams)
    
    func didFinish(session: PlayMediaWithSubtitlesUseStateControllerActiveSession)
    
    func pause(session: PlayMediaWithSubtitlesUseStateControllerActiveSession) -> Result<Void, PlayMediaWithSubtitlesUseCaseError>
    
    func didPause(controller: PausedPlayMediaWithSubtitlesUseStateController)
    
    func play(
        atTime: TimeInterval,
        session: PlayMediaWithSubtitlesUseStateControllerActiveSession
    ) -> Result<Void, PlayMediaWithSubtitlesUseCaseError>
    
    func didStartPlaying(
        withController: PlayingPlayMediaWithSubtitlesUseStateController
    )
    
    func resumePlaying(session: PlayMediaWithSubtitlesUseStateControllerActiveSession) -> Result<Void, PlayMediaWithSubtitlesUseCaseError>

    func didResumePlaying(withController: PlayingPlayMediaWithSubtitlesUseStateController)
    
    func stop(session: PlayMediaWithSubtitlesUseStateControllerActiveSession) -> Result<Void, PlayMediaWithSubtitlesUseCaseError>
    
    func didStop()
}
