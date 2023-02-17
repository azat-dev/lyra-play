//
//  TextSplitterImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 23.01.23.
//

import Foundation

public class TextSplitterImplFactory: TextSplitterFactory {
    
    // MARK: - Initializers
    
    public init() {}
    
    // MARK: - Methods
    
    public func make() -> TextSplitter {
        
        return TextSplitterImpl()
    }
}
