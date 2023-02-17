//
//  InitialPlayMediaUseCaseStateControllerFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 14.02.23.
//

import Foundation

public protocol InitialPlayMediaUseCaseStateControllerFactory: AnyObject {
    
    func make(delegate: PlayMediaUseCaseStateControllerDelegate) -> PlayMediaUseCaseStateController
}
