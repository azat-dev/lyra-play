//
//  GetLastPlayedMediaUseCaseImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 25.03.23.
//

import Foundation

public final class GetLastPlayedMediaUseCaseImpl: GetLastPlayedMediaUseCase {
    
    // MARK: - Properties
    
    private let mediaLibraryRepository: MediaLibraryRepository
    
    // MARK: - Initializers
    
    public init(mediaLibraryRepository: MediaLibraryRepository) {
        
        self.mediaLibraryRepository = mediaLibraryRepository
    }
    
    // MARK: - Methods
    
    public func getLastPlayedMedia() async -> Result<UUID?, GetLastPlayedMediaUseCaseError> {
        
        let result = await mediaLibraryRepository.getLastPlayedFile()
        
        guard case .success(let fileId) = result else {
            return .failure(.internalError)
        }

        return .success(fileId)
    }
}
