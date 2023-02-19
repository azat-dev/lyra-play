//
//  InitialPlayMediaUseCaseStateControllerImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.02.23.
//

import Foundation

public final class InitialPlayMediaUseCaseStateControllerImplFactory: InitialPlayMediaUseCaseStateControllerFactory {

    // MARK: - Initializers
    
    public init() {}
    
    // MARK: - Methods
    
    public func make(delegate: PlayMediaUseCaseStateControllerDelegate) -> InitialPlayMediaUseCaseStateController {
        return InitialPlayMediaUseCaseStateControllerImpl(delegate: delegate)
    }
}
