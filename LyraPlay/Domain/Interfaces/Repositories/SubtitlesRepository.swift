//
//  SubtitlesRepository.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 06.07.22.
//

import Foundation

// MARK: - Interfaces

public enum SubtitlesRepositoryError: Error {

    case itemNotFound
    case internalError(Error?)
}

public protocol SubtitlesRepository {
    
    func put(info: SubtitlesInfo) async -> Result<SubtitlesInfo, SubtitlesRepositoryError>
    
    func fetch(mediaFileId: UUID, language: String) async -> Result<SubtitlesInfo, SubtitlesRepositoryError>
    
    func list() async -> Result<[SubtitlesInfo], SubtitlesRepositoryError>

    func list(mediaFileId: UUID) async -> Result<[SubtitlesInfo], SubtitlesRepositoryError>
    
    func delete(mediaFileId: UUID, language: String) async -> Result<Void, SubtitlesRepositoryError>
}
