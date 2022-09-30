//
//  PlayMediaWithInfoUseCaseFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 30.09.22.
//

import Foundation

public protocol PlayMediaWithInfoUseCaseFactory {
    
    func create() -> PlayMediaWithInfoUseCase
}

