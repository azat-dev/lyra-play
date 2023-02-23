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
    
    // MARK: - Initializers
    
    public init(
        params: PlayMediaWithSubtitlesSessionParams,
        delegate: PlayMediaWithSubtitlesUseStateControllerDelegate,
        playMediaUseCaseFactory: PlayMediaUseCaseFactory,
        loadSubtitlesUseCaseFactory: LoadSubtitlesUseCaseFactory,
        playSubtitlesUseCaseFactory: PlaySubtitlesUseCaseFactory
    ) {
        
        self.params = params
        self.playMediaUseCaseFactory = playMediaUseCaseFactory
        self.loadSubtitlesUseCaseFactory = loadSubtitlesUseCaseFactory
        self.playSubtitlesUseCaseFactory = playSubtitlesUseCaseFactory

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
            delegate: nil
        )
        
        delegate?.didLoad(
            session: .init(
                params: params,
                playMediaUseCase: playMediaUseCase,
                playSubtitlesUseCase: playSubtitlesUseCase,
                subtitlesState: .init(
                    .init(
                        position: playSubtitlesUseCase.state.value.position,
                        subtitles: subtitles
                    )
                )
            )
        )
        
        return .success(())
    }
}
