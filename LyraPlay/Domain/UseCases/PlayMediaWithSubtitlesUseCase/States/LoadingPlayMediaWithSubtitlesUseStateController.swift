//
//  DelegatePlayMediaWithSubtitlesUseStateControllerImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 17.02.23.
//

import Foundation

public final class LoadingPlayMediaWithSubtitlesUseStateController: InitialPlayMediaWithSubtitlesUseStateController {
    
    // MARK: - Properties
    
    private let params: PlayMediaWithSubtitlesSessionParams
    private let playMediaUseCaseFactory: PlayMediaUseCaseFactory
    private let loadSubtitlesUseCaseFactory: LoadSubtitlesUseCaseFactory
    private let playSubtitlesUseCaseFactory: PlaySubtitlesUseCaseFactory
    private weak var playSubtitlesUseCaseDelegate: PlaySubtitlesUseCaseDelegate?
    
    // MARK: - Initializers
    
    public init(
        params: PlayMediaWithSubtitlesSessionParams,
        delegate: PlayMediaWithSubtitlesUseStateControllerDelegate,
        playMediaUseCaseFactory: PlayMediaUseCaseFactory,
        loadSubtitlesUseCaseFactory: LoadSubtitlesUseCaseFactory,
        playSubtitlesUseCaseFactory: PlaySubtitlesUseCaseFactory,
        playSubtitlesUseCaseDelegate: PlaySubtitlesUseCaseDelegate
    ) {
        
        self.params = params
        self.playMediaUseCaseFactory = playMediaUseCaseFactory
        self.loadSubtitlesUseCaseFactory = loadSubtitlesUseCaseFactory
        self.playSubtitlesUseCaseFactory = playSubtitlesUseCaseFactory
        self.playSubtitlesUseCaseDelegate = playSubtitlesUseCaseDelegate

        super.init(delegate: delegate)
    }
    
    // MARK: - Methods
    
    public override func prepare(params: PlayMediaWithSubtitlesSessionParams) async -> Result<Void, PlayMediaWithSubtitlesUseCaseError> {
        
        guard let delegate = delegate else {
            return .failure(.internalError(nil))
        }
        
        return await delegate.load(params: params)
    }
    
    public func load() async -> Result<Void, PlayMediaWithSubtitlesUseCaseError> {
        
        let mediaId = params.mediaId
        
        let playMediaUseCase = playMediaUseCaseFactory.make()
        let loadSubtitlesUseCase = loadSubtitlesUseCaseFactory.make()
        
        async let loadMediaPromise = await playMediaUseCase.prepare(mediaId: mediaId)
        
        async let loadSubtitlesPromise = await loadSubtitlesUseCase.load(
            for: params.mediaId,
            language: params.subtitlesLanguage
        )
        
        guard case .success = await loadMediaPromise else {
            
            delegate?.didFailLoad(params: params)
            return .failure(.internalError(nil))
        }
        
        guard case .success(let subtitles) = await loadSubtitlesPromise else {
            
            delegate?.didLoad(
                session: .init(
                    params: params,
                    playMediaUseCase: playMediaUseCase,
                    playSubtitlesUseCase: nil,
                    subtitlesState: .init(nil)
                )
            )
            return .failure(.internalError(nil))
        }
        
        let playSubtitlesUseCase = playSubtitlesUseCaseFactory.make(
            subtitles: subtitles,
            delegate: playSubtitlesUseCaseDelegate
        )
        
        delegate?.didLoad(
            session: .init(
                params: params,
                playMediaUseCase: playMediaUseCase,
                playSubtitlesUseCase: playSubtitlesUseCase,
                subtitlesState: .init(
                    .init(
                        timeSlot: playSubtitlesUseCase.subtitlesTimeSlot.value,
                        subtitles: subtitles,
                        timeSlots: playSubtitlesUseCase.timeSlots
                    )
                )
            )
        )
        
        return .success(())
    }
    
    public override func setTime(_ time: TimeInterval) {
    }
}
