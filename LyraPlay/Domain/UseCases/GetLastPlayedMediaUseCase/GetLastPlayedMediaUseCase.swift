//
//  GetLastPlayedMediaUseCase.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 25.03.23.
//

import Foundation

public enum GetLastPlayedMediaUseCaseError: Error {
    
    case internalError
}

public protocol GetLastPlayedMediaUseCase {
    
    func getLastPlayedMedia() async -> Result<UUID?, GetLastPlayedMediaUseCaseError>
}
