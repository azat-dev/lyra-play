//
//  GetPlayedTimeUseCaseImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 04.03.23.
//

import Foundation

public final class GetPlayedTimeUseCaseImpl: GetPlayedTimeUseCase {
    
    // MARK: - Properties
    
    private let mediaLibraryRepository: MediaLibraryRepositoryOutput
    
    // MARK: - Initializers
    
    public init(mediaLibraryRepository: MediaLibraryRepositoryOutput) {
        self.mediaLibraryRepository = mediaLibraryRepository
    }
    
    // MARK: - Methods
    
    public func getPlayedTime(for mediaId: UUID) async -> Result<TimeInterval, GetPlayedTimeUseCaseError> {
        
        return .failure(.internalError)
    }
}
