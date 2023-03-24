//
//  GetLastPlayedMediaUseCaseFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 25.03.23.
//

import Foundation

public protocol GetLastPlayedMediaUseCaseFactory {
    
    typealias UseCase = GetLastPlayedMediaUseCase
    
    func make() -> UseCase
}

