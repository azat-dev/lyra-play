//
//  PlayMediaWithInfoSession.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 29.09.22.
//

import Foundation

public struct PlayMediaWithInfoSession: Equatable {
    
    // MARK: - Properties
    
    public var mediaId: UUID
    public var learningLanguage: String
    public var nativeLanguage: String
    
    // MARK: - Initializers
    
    public init(
        mediaId: UUID,
        learningLanguage: String,
        nativeLanguage: String
    ) {
        
        self.mediaId = mediaId
        self.learningLanguage = learningLanguage
        self.nativeLanguage = nativeLanguage
    }
}
