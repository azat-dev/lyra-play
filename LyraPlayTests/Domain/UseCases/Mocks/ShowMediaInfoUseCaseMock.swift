//
//  ShowMediaInfoUseCaseMock.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 05.07.22.
//

import Foundation
import LyraPlay

class ShowMediaInfoUseCaseMock: ShowMediaInfoUseCase {

    public var tracks = [UUID: MediaInfo]()
    
    func fetchInfo(trackId: UUID) async -> Result<MediaInfo, ShowMediaInfoUseCaseError> {
        
        guard let trackData = tracks[trackId] else {
            return .failure(.trackNotFound)
        }
        
        return .success(trackData)
    }
}
