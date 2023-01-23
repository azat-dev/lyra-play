//
//  TextSplitter.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 17.07.22.
//

import Foundation

// MARK: - Interfaces

public protocol TextSplitter {
    
    func split(text: String) -> [TextComponent]
}
