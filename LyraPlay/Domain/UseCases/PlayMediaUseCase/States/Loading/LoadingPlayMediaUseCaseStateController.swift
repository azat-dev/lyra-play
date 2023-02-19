//
//  LoadingPlayMediaUseCaseStateController.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 17.02.23.
//

import Foundation

public protocol LoadingPlayMediaUseCaseStateController: PlayMediaUseCaseStateController {
    
    func load() async -> Result<Void, PlayMediaUseCaseError>
}
