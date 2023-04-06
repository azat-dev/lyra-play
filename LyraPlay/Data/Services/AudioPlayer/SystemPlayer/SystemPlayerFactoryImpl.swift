//
//  SystemPlayerFactoryImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 06.04.23.
//

import Foundation

public final class SystemPlayerFactoryImpl: SystemPlayerFactory {
    
    // MARK: - Properties
    
    // MARK: - Initializers
    
    public init() {
        
    }
    
    // MARK: - Methods
    
    public func make(data: Data) throws -> SystemPlayer {
        return try SystemPlayerImpl(data: data)
    }
}
