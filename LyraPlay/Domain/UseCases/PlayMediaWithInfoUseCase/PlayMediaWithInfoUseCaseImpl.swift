//
//  PlayMediaWithInfoUseCaseImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 29.09.22.
//

import Foundation
import Combine

public final class PlayMediaWithInfoUseCaseImpl: PlayMediaWithInfoUseCase {
    
    // MARK: - Properties
    
    private let playMediaWithTranslationsUseCase: PlayMediaWithTranslationsUseCase
    private let showMediaInfoUseCaseFactory: ShowMediaInfoUseCaseFactory
    
    public var state = PublisherWithSession<PlayMediaWithInfoUseCaseState, Never>(.noActiveSession)
    
    private var currentMediaInfo: MediaInfo?
    private var currentSession: PlayMediaWithInfoSession?
    
    private var observers = Set<AnyCancellable>()
    
    // MARK: - Initializers
    
    public init(
        playMediaWithTranslationsUseCaseFactory: PlayMediaWithTranslationsUseCaseFactory,
        showMediaInfoUseCaseFactory: ShowMediaInfoUseCaseFactory
    ) {
        
        self.playMediaWithTranslationsUseCase = playMediaWithTranslationsUseCaseFactory.create()
        self.showMediaInfoUseCaseFactory = showMediaInfoUseCaseFactory
    }
    
    deinit {
        observers.removeAll()
    }

    // MARK: - Methods
    
    private func map(_ state: PlayMediaWithTranslationsUseCaseState) -> PlayMediaWithInfoUseCaseState {
        
        switch state {

        case .noActiveSession:
            return .noActiveSession

        case .activeSession(_, let loadState):
            return .activeSession(currentSession!, map(loadState))
        }
    }
    
    private func map(_ loadState: PlayMediaWithTranslationsUseCaseLoadState) -> PlayMediaWithInfoUseCaseLoadState {
        
        switch loadState {
        
        case .loading:
            return .loading
        
        case .loadFailed:
            return .loadFailed
            
        case .loaded(let playerState, let subtitlesState):
            return .loaded(playerState, subtitlesState, currentMediaInfo!)
        }
    }
}

extension PlayMediaWithInfoUseCaseImpl {

    public func prepare(session: PlayMediaWithInfoSession) async -> Result<Void, PlayMediaWithInfoUseCaseError> {
               
        state.value = .activeSession(session, .loading)

        let showMediaInfoUseCase = showMediaInfoUseCaseFactory.create()
        let fetchInfoResult = await showMediaInfoUseCase.fetchInfo(trackId: session.mediaId)
        
        guard case .success(let mediaInfo) = fetchInfoResult else {
            return .failure(fetchInfoResult.error!.map())
        }
        
        currentMediaInfo = mediaInfo
        currentSession = session
        
        let result = await playMediaWithTranslationsUseCase.prepare(
            session: .init(
                mediaId: session.mediaId,
                learningLanguage: session.learningLanguage,
                nativeLanguage: session.nativeLanguage
            )
        )
        
        guard case .success = result else {
            return .failure(result.error!.map())
        }
        
        observers.removeAll()
        
        playMediaWithTranslationsUseCase.state.publisher
            .sink { [weak self] value in
                
                guard let self = self else {
                    return
                }
                
                self.state.value = self.map(value)
            }
            .store(in: &observers)
        
        return .success(())
    }
    
    public func play() -> Result<Void, PlayMediaWithInfoUseCaseError> {
        
        return playMediaWithTranslationsUseCase.play().mapError { $0.map() }
    }
    
    public func play(atTime: TimeInterval) -> Result<Void, PlayMediaWithInfoUseCaseError> {
        
        return playMediaWithTranslationsUseCase.play(atTime: atTime).mapError { $0.map() }
    }
    
    public func pause() -> Result<Void, PlayMediaWithInfoUseCaseError> {
        
        return playMediaWithTranslationsUseCase.pause().mapError { $0.map() }
    }
    
    public func stop() -> Result<Void, PlayMediaWithInfoUseCaseError> {
        
        return playMediaWithTranslationsUseCase.stop().mapError { $0.map() }
    }
    
    public func togglePlay() -> Result<Void, PlayMediaWithInfoUseCaseError> {
        
        return playMediaWithTranslationsUseCase.togglePlay().mapError { $0.map() }
    }
}

// MARK: - Error Mappings

extension PlayMediaWithTranslationsUseCaseError {
    
    func map() -> PlayMediaWithInfoUseCaseError {
        
        switch self {
        
        case .mediaFileNotFound:
            return .mediaFileNotFound
        
        case .noActiveMedia:
            return .noActiveMedia
            
        case .internalError(let error):
            return .internalError(error)
            
        case .taskCancelled:
            return .taskCancelled
        }
    }
}

extension ShowMediaInfoUseCaseError {
    
    func map() -> PlayMediaWithInfoUseCaseError {

        switch self {
            
        case .trackNotFound:
            return .mediaFileNotFound
            
        case .internalError(let error):
            return .internalError(error)
        }
    }
}
