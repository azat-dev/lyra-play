//
//  PlayerViewModel.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 30.06.22.
//

import Foundation
import UIKit

// MARK: - Interfaces

public enum CurrentPlayerState {
    
    case paused
    case running
    case stopped
}

public protocol PlayerViewModelOutput {
    
    var currentTime: Observable<Float> { get }
    var state: Observable<CurrentPlayerState> { get }
    var volume: Observable<Float> { get }
    var image: Observable<UIImage?> { get }
}

public protocol PlayerViewModelInput {
    
    func play()
    
    func pause()
    
    func setVolume()
}

public protocol PlayerViewModel: PlayerViewModelOutput, PlayerViewModelInput {
    
}

// MARK: - Implementations

public final class DefaultPlayerViewModel: PlayerViewModel {
    
    private let audioPlayerUseCase: AudioPlayerUseCase
    
    public var currentTime: Observable<Float>
    public var state: Observable<CurrentPlayerState>
    public var volume: Observable<Float>
    public var image: Observable<UIImage?>
    
    public init(audioPlayerUseCase: AudioPlayerUseCase) {
        
        self.audioPlayerUseCase = audioPlayerUseCase
        
        currentTime = Observable(0)
        state = Observable(.stopped)
        volume = Observable(0)
        image = Observable(nil)
    }
    
    public func play() {
        fatalError()
    }
    
    public func pause() {
        fatalError()
    }
    
    public func setVolume() {
        fatalError()
    }
}
