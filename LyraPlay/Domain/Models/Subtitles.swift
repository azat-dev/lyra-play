//
//  Subtitles.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 06.07.22.
//

import Foundation


struct SubtitleItem {
    
    var startTime: Double
    var duration: Double
    
    var words: [String]
}

struct Subtitles {

    var items: [SubtitleItem]
}
