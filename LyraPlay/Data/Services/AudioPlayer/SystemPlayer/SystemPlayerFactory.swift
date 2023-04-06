//
//  SystemPlayerFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 06.04.23.
//

import Foundation

public protocol SystemPlayerFactory {
    
    func make(data: Data) throws -> SystemPlayer
}
