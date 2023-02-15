//
//  FinishedPlayMediaUseCaseStateController.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 15.02.23.
//

import Foundation

public class FinishedPlayMediaUseCaseStateController: PausedPlayMediaUseCaseStateController {
    
    public override init(
        mediaId: UUID,
        audioPlayer: AudioPlayer,
        context: PlayMediaUseCaseStateControllerContext,
        statesFactories: PausedPlayMediaUseCaseStateControllerFactories
    ) {
        
        super.init(
            mediaId: mediaId,
            audioPlayer: audioPlayer,
            context: context,
            statesFactories: statesFactories
        )
        
        state = .finished(mediaId: mediaId)
    }
    
    public override func play(atTime: TimeInterval) {
        super.play(atTime: 0)
    }
}
