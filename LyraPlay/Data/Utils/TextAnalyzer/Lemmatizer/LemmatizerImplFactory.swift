//
//  LemmatizerImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 23.01.23.
//

import Foundation

public class LemmatizerImplFactory: LemmatizerFactory {
    
    // MARK: - Initializers
    
    public init() {}
    
    // MARK: - Methods
    
    public func make() -> Lemmatizer {
        
        return LemmatizerImpl()
    }
}
