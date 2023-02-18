//
//  FailedLoadPlayMediaUseCaseStateController.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 15.02.23.
//

import Foundation

public class FailedLoadPlayMediaUseCaseStateControllerImpl: InitialPlayMediaUseCaseStateControllerImpl, FailedLoadPlayMediaUseCaseStateController {
    
    // MARK: - Properties
    
    private let mediaId: UUID
    private weak var delegate: PlayMediaUseCaseStateControllerDelegate?
    
    // MARK: - Initializers

    public init(
        mediaId: UUID,
        delegate: PlayMediaUseCaseStateControllerDelegate
    ) {
        
        self.mediaId = mediaId
        self.delegate = delegate
        
        super.init(delegate: delegate)
    }
}
