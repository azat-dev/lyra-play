//
//  PlayMediaUseCaseImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 31.08.2022.
//

import Foundation

public final class PlayMediaUseCaseImplFactory: PlayMediaUseCaseFactory {
    
    // MARK: - Properties
    
    private let loadTrackUseCaseFactory: LoadTrackUseCaseFactory
    private let audioPlayerFactory: AudioPlayerFactory
    private let getPlayedTimeUseCaseFactory: GetPlayedTimeUseCaseFactory
    private let updatePlayedTimeUseCaseFactory: UpdatePlayedTimeUseCaseFactory
    
    
    // MARK: - Initializers
    
    public init(
        loadTrackUseCaseFactory: LoadTrackUseCaseFactory,
        audioPlayerFactory: AudioPlayerFactory,
        getPlayedTimeUseCaseFactory: GetPlayedTimeUseCaseFactory,
        updatePlayedTimeUseCaseFactory: UpdatePlayedTimeUseCaseFactory
    ) {

        self.loadTrackUseCaseFactory = loadTrackUseCaseFactory
        self.audioPlayerFactory = audioPlayerFactory
        self.getPlayedTimeUseCaseFactory = getPlayedTimeUseCaseFactory
        self.updatePlayedTimeUseCaseFactory = updatePlayedTimeUseCaseFactory
    }

    // MARK: - Methods
    
    public func make() -> PlayMediaUseCase {
        
        return PlayMediaUseCaseImpl(
            loadTrackUseCaseFactory: loadTrackUseCaseFactory,
            audioPlayerFactory: audioPlayerFactory,
            getPlayedTimeUseCaseFactory: getPlayedTimeUseCaseFactory,
            updatePlayedTimeUseCaseFactory: updatePlayedTimeUseCaseFactory
        )
    }
}
