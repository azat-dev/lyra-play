//
//  TextSplitterMock.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 21.07.22.
//

import Foundation
import LyraPlay

final class TextSplitterMock: TextSplitter {
    
    var words = [TextComponent]()
    
    func split(text: String) -> [TextComponent] {
    
        return words
    }
}
