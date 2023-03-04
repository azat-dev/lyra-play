//
//  UpdatePlayedTimeUseCaseFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 05.03.23.
//

import Foundation

public protocol UpdatePlayedTimeUseCaseFactory {
    
    func make() -> UpdatePlayedTimeUseCase
}
