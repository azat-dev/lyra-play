//
//  UpdatePlayedTimeUseCaseImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 05.03.23.
//

import Foundation

public final class UpdatePlayedTimeUseCaseImplFactory: UpdatePlayedTimeUseCaseFactory {
    
    // MARK: - Properties
    
    private let mediaLibraryRepository: MediaLibraryRepositoryInput
    
    // MARK: - Initializers
    
    public init(mediaLibraryRepository: MediaLibraryRepositoryInput) {
        
        self.mediaLibraryRepository = mediaLibraryRepository
    }
    
    // MARK: - Methods
    
    public func make() -> UpdatePlayedTimeUseCase {
        
        return UpdatePlayedTimeUseCaseImpl(mediaLibraryRepository: mediaLibraryRepository)
    }
}
