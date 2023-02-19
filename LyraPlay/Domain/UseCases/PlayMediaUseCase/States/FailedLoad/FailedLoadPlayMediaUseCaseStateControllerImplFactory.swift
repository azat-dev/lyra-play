//
//  FailedLoadPlayMediaUseCaseStateControllerImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.02.23.
//

import Foundation

public final class FailedLoadPlayMediaUseCaseStateControllerImplFactory: FailedLoadPlayMediaUseCaseStateControllerFactory {
    
    // MARK: - Initializers
    
    public init() {}
    
    // MARK: - Methods
    
    public func make(
        mediaId: UUID,
        delegate: PlayMediaUseCaseStateControllerDelegate
    ) -> FailedLoadPlayMediaUseCaseStateController {
        
        return FailedLoadPlayMediaUseCaseStateControllerImpl(
            mediaId: mediaId,
            delegate: delegate
        )
    }
}
