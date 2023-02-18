//
//  DelegatePlayMediaWithSubtitlesUseStateController.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 17.02.23.
//

import Foundation

public class LoadingPlayMediaWithSubtitlesUseStateController: PlayMediaWithSubtitlesUseStateController {
    
    // MARK: - Properties
    
    private weak var delegate: PlayMediaWithSubtitlesUseStateControllerDelegate?
    
    private let params: PlayMediaWithSubtitlesSessionParams
    private let playMediaUseCaseFactory: PlayMediaUseCaseFactory
    private let loadSubtitlesUseCaseFactory: LoadSubtitlesUseCaseFactory
    
    // MARK: - Initializers
    
    public init(
        params: PlayMediaWithSubtitlesSessionParams,
        delegate: PlayMediaWithSubtitlesUseStateControllerDelegate,
        playMediaUseCaseFactory: PlayMediaUseCaseFactory,
        loadSubtitlesUseCaseFactory: LoadSubtitlesUseCaseFactory
    ) {
        self.params = params
        self.delegate = delegate
        self.playMediaUseCaseFactory = playMediaUseCaseFactory
        self.loadSubtitlesUseCaseFactory = loadSubtitlesUseCaseFactory
    }
    
    // MARK: - Methods
    
    public func prepare(params: PlayMediaWithSubtitlesSessionParams) async -> Result<Void, PlayMediaWithSubtitlesUseCaseError> {
        
        delegate?.didStartLoading(params: params)
        return .success(())
    }
    
    public func play() -> Result<Void, PlayMediaWithSubtitlesUseCaseError> {
        return .success(())
    }
    
    public func play(atTime: TimeInterval) -> Result<Void, PlayMediaWithSubtitlesUseCaseError> {
        return .success(())
    }
    
    public func pause() -> Result<Void, PlayMediaWithSubtitlesUseCaseError> {
        return .success(())
    }
    
    public func stop() -> Result<Void, PlayMediaWithSubtitlesUseCaseError> {
        return .success(())
    }
    
    public func togglePlay() -> Result<Void, PlayMediaWithSubtitlesUseCaseError> {
        return .success(())
    }
    
    public func execute() {
        
        Task {
            
            let mediaId = params.mediaId
            
            let playMediaUseCase = playMediaUseCaseFactory.make()
            let loadSubtitlesUseCase = loadSubtitlesUseCaseFactory.make()
            
            async let loadMediaResult = await playMediaUseCase.prepare(mediaId: mediaId)
            
//
//            async let loadSubtitlesResult = await loadSubtitlesUseCase.load(
//                for: params.mediaId,
//                language: params.subtitlesLanguage
//            )
//
//            guard case .success = loadMediaResult else {
//                delegate?.didFailLoad(mediaId: mediaId)
//                return
//            }
//
//            guard case .success(let subtitles) = loadSubtitlesResult else {
//                delegate?.didLoad(
//                    params: params,
//                    subtitlesState: nil,
//                    playMediaUseCase: playMediaUseCase
//                )
//                return
//            }
//
//            delegate?.didLoad(
//                params: params,
//                subtitlesState: nil,
//                playMediaUseCase: playMediaUseCase
//            )
        }
    }
}
