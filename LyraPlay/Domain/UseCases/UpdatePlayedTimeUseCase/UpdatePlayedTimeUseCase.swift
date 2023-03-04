//
//  UpdatePlayedTimeUseCase.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 04.03.23.
//

import Foundation

public enum UpdatePlayedTimeUseCaseError: Error {
    
    case internalError
    case mediaNotFound
}

public protocol UpdatePlayedTimeUseCase {
    
    func updatePlayedTime(for mediaId: UUID, time: TimeInterval) async -> Result<Void, UpdatePlayedTimeUseCaseError>
}
