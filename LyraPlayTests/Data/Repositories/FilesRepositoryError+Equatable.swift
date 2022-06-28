//
//  FilesRepositoryError+Equatable.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 28.06.22.
//

import Foundation
import LyraPlay

extension FilesRepositoryError: Equatable {
    public static func == (lhs: FilesRepositoryError, rhs: FilesRepositoryError) -> Bool {
        
        switch (lhs, rhs) {
        case (.internalError, .internalError):
            return true
        case (.fileNotFound, .fileNotFound):
            return true
        default:
            return false
        }
    }
}
