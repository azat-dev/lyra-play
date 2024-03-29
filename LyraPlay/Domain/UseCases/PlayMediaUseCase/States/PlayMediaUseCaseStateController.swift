//
//  PlayMediaUseCaseStateController.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 09.02.23.
//

import Foundation

public protocol PlayMediaUseCaseStateController: PlayMediaUseCaseInput {
    
    var currentTime: TimeInterval { get }
    
    var duration: TimeInterval { get }
}
