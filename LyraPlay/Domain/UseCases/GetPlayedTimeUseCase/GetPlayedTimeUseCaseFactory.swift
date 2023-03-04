//
//  GetPlayedTimeUseCaseFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 04.03.23.
//

import Foundation

public protocol GetPlayedTimeUseCaseFactory: AnyObject {
    
    func make() -> GetPlayedTimeUseCase
}
