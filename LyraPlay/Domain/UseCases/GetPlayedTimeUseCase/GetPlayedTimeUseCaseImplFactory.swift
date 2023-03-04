//
//  GetPlayedTimeUseCaseImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 04.03.23.
//

import Foundation

public final class GetPlayedTimeUseCaseImplFactory: GetPlayedTimeUseCaseFactory {
    
    // MARK: - Properties
    
    private let mediaLibraryRepository: MediaLibraryRepositoryOutput
    
    // MARK: - Initializers
    
    public init(mediaLibraryRepository: MediaLibraryRepositoryOutput) {
        
        self.mediaLibraryRepository = mediaLibraryRepository
    }
    
    // MARK: - Methods
    
    public func make() -> GetPlayedTimeUseCase {
        
        return GetPlayedTimeUseCaseImpl(mediaLibraryRepository: mediaLibraryRepository)
    }
}
