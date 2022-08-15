//
//  Subtitles+Helpers.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 15.08.22.
//

import Foundation
import LyraPlay

extension Subtitles.Sentence {
    
    static func anySentence(
        at: TimeInterval,
        duration: TimeInterval? = nil,
        timeMarks: [Subtitles.TimeMark]? = nil,
        text: String? = nil
    ) -> Subtitles.Sentence {
        
        return .init(
            startTime: at,
            duration: duration,
            text: text ?? "",
            timeMarks: timeMarks,
            components: []
        )
    }
}

extension Subtitles.TimeMark {
    
    static func anyTimeMark(at: TimeInterval, duration: TimeInterval? = nil) -> Subtitles.TimeMark {
        
        let dummyRange = "a".range(of: "a")!
        
        return .init(
            startTime: at,
            duration: duration,
            range: dummyRange
        )
    }
}
