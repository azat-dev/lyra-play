//
//  LoadTrackUseCaseMock.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 05.07.22.
//

import Foundation
import LyraPlay

class LoadTrackUseCaseMock: LoadTrackUseCase {
    
    public var tracks = [UUID: Data]()
    
    public func load(trackId: UUID) async -> Result<Data, LoadTrackUseCaseError> {
        
        guard let data = tracks[trackId] else {
            return .failure(.trackNotFound)
        }
        
        return .success(data)
    }
}
