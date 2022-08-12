//
//  PlayMediaUseCaseMock.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 01.07.22.
//

import Foundation
import LyraPlay

final class PlayMediaUseCaseMock: PlayMediaUseCase {
    
    private var currentTrackId: UUID? = nil
    private var currentPlayerStateUseCase: CurrentPlayerStateUseCaseMock?
    var state: Observable<PlayMediaUseCaseState> = .init(.initial)
    
    public init(currentPlayerStateUseCase: CurrentPlayerStateUseCaseMock? = nil) {
        
        self.currentPlayerStateUseCase = currentPlayerStateUseCase
    }
    
    var prepareWillReturn: ((_ mediaId: UUID) -> Result<Void, PlayMediaUseCaseError>)?
    
    func prepare(mediaId: UUID) async -> Result<Void, PlayMediaUseCaseError> {
        
        if let prepareWillReturn = prepareWillReturn {
            return prepareWillReturn(mediaId)
        }
        
        currentTrackId = mediaId
        self.state.value = .loading(mediaId: mediaId)
        self.state.value = .loaded(mediaId: mediaId, data: "".data(using: .utf8)!)
        
        return .success(())
    }
    
    func play() async -> Result<Void, PlayMediaUseCaseError> {
        
        guard let currentTrackId = currentTrackId else {
            return .failure(.noActiveTrack)
        }
        
        await currentPlayerStateUseCase?.setTrack(trackId: currentTrackId)
        currentPlayerStateUseCase?.state.value = .playing
        
        self.state.value = .playing(mediaId: currentTrackId)
        
        return .success(())
    }
    
    func pause() async -> Result<Void, PlayMediaUseCaseError> {
        
        guard  currentTrackId != nil else {
            return .failure(.noActiveTrack)
        }
        
        currentPlayerStateUseCase?.state.value = .paused
        state.value = .paused(mediaId: currentTrackId!, time: 0)
        return .success(())
    }
    
    func stop() async -> Result<Void, PlayMediaUseCaseError> {
        
        currentTrackId = nil
        state.value = .stopped
        
        return .success(())
    }
    
    func finish() {
        
        guard let currentTrackId = currentTrackId else {
            fatalError("No active track")
        }
        
        self.state.value = .finished(mediaId: currentTrackId)
    }
}
