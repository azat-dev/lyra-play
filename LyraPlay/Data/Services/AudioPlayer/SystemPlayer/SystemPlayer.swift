//
//  SystemPlayer.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 06.04.23.
//

import Foundation

public protocol SystemPlayerDelegate: AnyObject {
    
    func audioPlayerDidFinishPlaying(player: SystemPlayer, successfully: Bool)
}

public protocol SystemPlayer: AnyObject {
    
    // MARK: - Properties
    
    var currentTime: TimeInterval { get set }
    
    var duration: TimeInterval { get }
    
    var delegate: SystemPlayerDelegate? { get set }
    
    // MARK: - Methods

    func stop()
    
    func pause()
    
    func prepareToPlay() -> Bool
    
    func play() -> Bool

    func play(atTime: TimeInterval) -> Bool
    
    // MARK: - Initializers
    
    init(data: Data) throws
}
