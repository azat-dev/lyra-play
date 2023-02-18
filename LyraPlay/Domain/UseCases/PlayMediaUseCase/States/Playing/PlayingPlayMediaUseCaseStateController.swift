//
//  PlayingPlayMediaUseCaseStateController.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 17.02.23.
//

import Foundation

public protocol PlayingPlayMediaUseCaseStateController: PlayMediaUseCaseStateController {
    
    func run() -> Result<Void, PlayMediaUseCaseError>
}
