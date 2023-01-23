//
//  TextSplitterFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 23.01.23.
//

import Foundation

public protocol TextSplitterFactory {
    
    func create() -> TextSplitter
}
