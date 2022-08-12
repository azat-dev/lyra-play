//
//  PlayMediaWithSubtitlesUseCase.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 12.08.2022.
//

import Foundation

// MARK: - Interfaces

public enum PlayMediaWithSubtitlesUseCaseError: Error {
    
    case mediaFileNotFound
    case internalError(Error?)
    case noActiveMedia
}

public enum PlayMediaWithSubtitlesUseCaseState: Equatable {
    
    case initial
    case loading(session: PlayMediaWithSubtitlesSessionParams)
    case loadFailed(session: PlayMediaWithSubtitlesSessionParams)
    case loaded(session: PlayMediaWithSubtitlesSessionParams, subtitlesState: SubtitlesState?)
    case playing(session: PlayMediaWithSubtitlesSessionParams, subtitlesState: SubtitlesState?)
    case interrupted(session: PlayMediaWithSubtitlesSessionParams, subtitlesState: SubtitlesState?, time: TimeInterval)
    case paused(session: PlayMediaWithSubtitlesSessionParams, subtitlesState: SubtitlesState?, time: TimeInterval)
    case finished(session: PlayMediaWithSubtitlesSessionParams)
}

public struct SubtitlesState: Equatable {
    
    public var position: SubtitlesPosition?
    public var subtitles: Subtitles
    
    public init(
        position: SubtitlesPosition?,
        subtitles: Subtitles
    ) {
        
        self.position = position
        self.subtitles = subtitles
    }
}

public struct PlayMediaWithSubtitlesSessionParams: Equatable {
    
    public var mediaId: UUID
    public var subtitlesLanguage: String
    
    public init(
        mediaId: UUID,
        subtitlesLanguage: String
    ) {
        
        self.mediaId = mediaId
        self.subtitlesLanguage = subtitlesLanguage
    }
}
public protocol PlayMediaWithSubtitlesUseCaseInput {
    
    func prepare(params: PlayMediaWithSubtitlesSessionParams) async -> Result<Void, PlayMediaWithSubtitlesUseCaseError>
    
    func play() async -> Result<Void, PlayMediaWithSubtitlesUseCaseError>
    
    func play(at time: TimeInterval?) async -> Result<Void, PlayMediaWithSubtitlesUseCaseError>
    
    func pause() async -> Result<Void, PlayMediaWithSubtitlesUseCaseError>
    
    func stop() async -> Result<Void, PlayMediaWithSubtitlesUseCaseError>
}

public protocol PlayMediaWithSubtitlesUseCaseOutput {
    
    var state: Observable<PlayMediaWithSubtitlesUseCaseState> { get }
}

public protocol PlayMediaWithSubtitlesUseCase: PlayMediaWithSubtitlesUseCaseOutput, PlayMediaWithSubtitlesUseCaseInput {
}

// MARK: - Implementations

public final class DefaultPlayMediaWithSubtitlesUseCase: PlayMediaWithSubtitlesUseCase {
    
    // MARK: - Properties
    
    private let playMediaUseCase: PlayMediaUseCase
    private let playSubtitlesUseCaseFactory: PlaySubtitlesUseCaseFactory
    private let loadSubtitlesUseCase: LoadSubtitlesUseCase
    
    public let state: Observable<PlayMediaWithSubtitlesUseCaseState> = .init(.initial)
    
    private var playSubtitlesUseCase: PlaySubtitlesUseCase?
    
    // MARK: - Initializers
    
    public init(
        playMediaUseCase: PlayMediaUseCase,
        playSubtitlesUseCaseFactory: PlaySubtitlesUseCaseFactory,
        loadSubtitlesUseCase: LoadSubtitlesUseCase
    ) {
        
        self.playMediaUseCase = playMediaUseCase
        self.playSubtitlesUseCaseFactory = playSubtitlesUseCaseFactory
        self.loadSubtitlesUseCase = loadSubtitlesUseCase
    }
}

// MARK: - Input methods

extension DefaultPlayMediaWithSubtitlesUseCase {
    
    public func prepare(params session: PlayMediaWithSubtitlesSessionParams) async -> Result<Void, PlayMediaWithSubtitlesUseCaseError> {
        
        state.value = .loading(session: session)
        
        let loadMediaResult = await playMediaUseCase.prepare(mediaId: session.mediaId)
        
        guard case .success = loadMediaResult else {
            
            state.value = .loadFailed(session: session)
            return .failure(map(error: loadMediaResult.error!))
        }
        
        let loadSubtitlesResult = await loadSubtitlesUseCase.load(
            for: session.mediaId,
            language: session.subtitlesLanguage
        )
        
        if case .success(let subtitles) = loadSubtitlesResult {
            
            playSubtitlesUseCase = playSubtitlesUseCaseFactory.create(with: subtitles)
            
            self.state.value = .loaded(
                session: session,
                subtitlesState: .init(
                    position: nil,
                    subtitles: subtitles
                )
            )
        } else {
            
            self.state.value = .loaded(session: session, subtitlesState: nil)
        }
        
        return .success(())
    }
    
    public func play() async -> Result<Void, PlayMediaWithSubtitlesUseCaseError> {
        return await play(at: nil)
    }
    
    public func play(at time: TimeInterval?) async -> Result<Void, PlayMediaWithSubtitlesUseCaseError> {

        fatalError("Not implemented")
    }
    
    public func pause() async -> Result<Void, PlayMediaWithSubtitlesUseCaseError> {
        
        fatalError("Not implemented")
    }
    
    public func stop() async -> Result<Void, PlayMediaWithSubtitlesUseCaseError> {
        
        fatalError("Not implemented")
    }
}

// MARK: - Error Mappings

extension DefaultPlayMediaWithSubtitlesUseCase {

    private func map(error: PlayMediaUseCaseError) -> PlayMediaWithSubtitlesUseCaseError {

        switch error {
            
        case .noActiveTrack:
            return .noActiveMedia
        
        case .trackNotFound:
            return .mediaFileNotFound
        
        case .internalError(let error):
            return .internalError(error)
        }
    }
}
