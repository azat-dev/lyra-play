//
//  PlayerViewModel.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 30.06.22.
//

import Foundation
import UIKit

// MARK: - Interfaces

public struct TrackInfo {
    
    var title: String
    var description: String
    var image: UIImage
    var duration: String
}

public protocol PlayerViewModelOutput {
    
    var trackInfo: Observable<TrackInfo?> { get }
    var isPlaying: Observable<Bool> { get }
    var progress: Observable<Float> { get }
    var currentTime: Observable<String> { get }
    var volume: Observable<Float> { get }
}

public protocol PlayerViewModelInput {

    func load() async
    func togglePlay() async
    func setVolume() async
}

public protocol PlayerViewModel: PlayerViewModelOutput, PlayerViewModelInput {
    
}

// MARK: - Implementations

public final class DefaultPlayerViewModel: PlayerViewModel {

    private let playerControlUseCase: PlayerControlUseCase
    
    public var trackInfo: Observable<TrackInfo?>
    public var isPlaying: Observable<Bool>
    public var progress: Observable<Float>
    public var currentTime: Observable<String>
    public var volume: Observable<Float>
    
    public init(playerControlUseCase: PlayerControlUseCase) {
        
        self.playerControlUseCase = playerControlUseCase
        
        trackInfo = Observable(nil)
        currentTime = Observable("0:00")
        volume = Observable(0)
        isPlaying = Observable(false)
        progress = Observable(0)
        
//        playerControlUseCase.isPlaying.observe(on: self) { [weak self] isPlaying in
//            self?.isPlaying.value = isPlaying
//        }
    }
    
    public func togglePlay() async {
        
//        if playerControlUseCase.isPlaying.value {
//            let _ = await playerControlUseCase.pause()
//        } else {
//            let _ = await playerControlUseCase.play()
//        }
    }
    
    public func setVolume() async {
        fatalError()
    }
    
    public func load() async {
        
        trackInfo.value = nil
        
//        playerControlUseCase.setTrack(fileId: UUID)
    }
}
