//
//  SubtitlesRepositoryFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 23.01.23.
//

import Foundation

public protocol SubtitlesRepositoryFactory {
    
    func make() -> SubtitlesRepository
}

