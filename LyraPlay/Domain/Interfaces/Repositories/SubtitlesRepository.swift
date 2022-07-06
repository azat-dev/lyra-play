//
//  SubtitlesRepository.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 06.07.22.
//

import Foundation

// MARK: - Interfaces

public enum SubtitlesRepositoryError: Error {
    
    case mediaFileNotFound
    case internalError(Error?)
}

public protocol SubtitlesRepository {
    
    func put(info: SubtitleInfo) async -> Result<SubtitleInfo, SubtitlesRepositoryError>
}
