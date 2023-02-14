//
//  PlayMediaUseCaseStateController.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 09.02.23.
//

import Foundation

public protocol PlayMediaUseCaseStateController {
    
    var state: PlayMediaUseCaseState { get }
    
    func prepare(mediaId: UUID)
    
    func play()
    
    func play(atTime: TimeInterval)
    
    func pause()
    
    func stop()
    
    func togglePlay()
}
