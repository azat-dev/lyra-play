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
        self.playMediaWithTranslationsUseCase = playMediaWithTranslationsUseCaseFactory.make()
        self.showMediaInfoUseCaseFactory = showMediaInfoUseCaseFactory
    }
    
    public func prepare(session: PlayMediaWithInfoSession) async -> Result<Void, PlayMediaWithInfoUseCaseError> {
        return .success(())
    }
    
    public func play() -> Result<Void, PlayMediaWithInfoUseCaseError> {
        return .success(())
    }
    
    public func play(atTime: TimeInterval) -> Result<Void, PlayMediaWithInfoUseCaseError> {
        return .success(())
    }
    
    public func pause() -> Result<Void, PlayMediaWithInfoUseCaseError> {
        return .success(())
    }
    
    public func stop() -> Result<Void, PlayMediaWithInfoUseCaseError> {
        return .success(())
    }
    
    public func togglePlay() -> Result<Void, PlayMediaWithInfoUseCaseError> {
        return .success(())
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

extension PlayMediaWithTranslationsUseCasePlayerState {
    
    func map() -> PlayMediaWithInfoUseCasePlayerState {
        
        switch self {
        
        case .initial:
            return .initial
        
        case .playing:
            return .playing
            
        case .pronouncingTranslations:
            return .pronouncingTranslations
            
        case .paused:
            return .paused
            
        case .stopped:
            return .stopped
            
        case .finished:
            return .finished
            
        case .loading, .loaded, .loadFailed:
            fatalError()
        }
    }
}
