//
//  InitialPlayMediaUseCaseStateControllerFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 14.02.23.
//

import Foundation

public protocol InitialPlayMediaUseCaseStateControllerFactories: LoadingPlayMediaUseCaseStateControllerFactory {}

public protocol InitialPlayMediaUseCaseStateControllerFactory: AnyObject {
    
    func makeInitial(context: PlayMediaUseCaseStateControllerContext) -> PlayMediaUseCaseStateController
}
