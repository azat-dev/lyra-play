//
//  TempURLProviderFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.01.23.
//

import Foundation

public protocol TempURLProviderFactory {
    
    func make() -> TempURLProvider
}
