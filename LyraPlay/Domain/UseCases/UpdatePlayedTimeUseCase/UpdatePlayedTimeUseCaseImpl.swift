//
//  UpdatePlayedTimeUseCaseImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 04.03.23.
//

import Foundation

public final class UpdatePlayedTimeUseCaseImpl: UpdatePlayedTimeUseCase {
    
    // MARK: - Properties
    
    private let mediaLibraryRepository: MediaLibraryRepositoryInput
    
    // MARK: - Initializers
    
    public init(mediaLibraryRepository: MediaLibraryRepositoryInput) {
        self.mediaLibraryRepository = mediaLibraryRepository
    }
    
    // MARK: - Methods
    
    public func updatePlayedTime(for mediaId: UUID, time: TimeInterval) async -> Result<Void, UpdatePlayedTimeUseCaseError> {
        
        let result = await mediaLibraryRepository.updateFileProgress(id: mediaId, time: time)
        
        guard case .success = result else {
            return .failure(result.error!.map())
        }

        return .success(())
    }
}

extension MediaLibraryRepositoryError {
    
    func map() -> UpdatePlayedTimeUseCaseError {
        
        switch self {
            
        case .fileNotFound:
            return .mediaNotFound
            
        default:
            return .internalError
        }
    }
}
