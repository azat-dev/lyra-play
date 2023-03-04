//
//  GetPlayedTimeUseCase.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 04.03.23.
//

import Foundation

public enum GetPlayedTimeUseCaseError: Error {
    
    case internalError
}

public protocol GetPlayedTimeUseCase: AnyObject {
 
    func getPlayedTime(for mediaId: UUID) async -> Result<TimeInterval?, GetPlayedTimeUseCaseError>
}
