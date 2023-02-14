//
//  PlayMediaUseCaseStateControllerContext.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 14.02.23.
//

import Foundation

public protocol PlayMediaUseCaseStateControllerContext: AnyObject {
    
    func set(newState: PlayMediaUseCaseStateController)
}
