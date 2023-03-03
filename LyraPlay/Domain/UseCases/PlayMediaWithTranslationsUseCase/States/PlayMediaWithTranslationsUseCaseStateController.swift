//
//  PlayMediaWithTranslationsUseCaseStateController.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 21.02.23.
//

import Foundation

public protocol PlayMediaWithTranslationsUseCaseStateController: AnyObject, PlayMediaWithTranslationsUseCaseInput {
    
    var currentTime: TimeInterval { get }
    
    var duration: TimeInterval { get }
}
