//
//  GetLastPlayedMediaUseCaseImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 25.03.23.
//

import Foundation

public final class GetLastPlayedMediaUseCaseImplFactory: GetLastPlayedMediaUseCaseFactory {
    
    // MARK: - Properties
    
    private let mediaLibraryRepository: MediaLibraryRepository
    
    // MARK: - Initializers
    
    public init(mediaLibraryRepository: MediaLibraryRepository) {
        self.mediaLibraryRepository = mediaLibraryRepository
    }
    
    // MARK: - Methods
    
    public func make() -> UseCase {
        
        return GetLastPlayedMediaUseCaseImpl(mediaLibraryRepository: mediaLibraryRepository)
    }
}
