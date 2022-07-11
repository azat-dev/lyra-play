//
//  SubtitlesIterator.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 11.07.22.
//

import Foundation

// MARK: - Interfaces

public protocol SubtitlesIterator {
    
    func searchRecentSentence(at: TimeInterval) -> (index: Int, sentence: Subtitles.Sentence)?
}

// MARK: - Implementations

public final class DefaultSubtitlesIterator: SubtitlesIterator {
    
    private var subtitles: Subtitles
    
    public init(subtitles: Subtitles) {
        
        self.subtitles = subtitles
    }
    
    
    public func searchRecentSentence(at time: TimeInterval) -> (index: Int, sentence: Subtitles.Sentence)? {
        
        let sentences = subtitles.sentences

        for index in 0..<sentences.count {
            
            let sentence = sentences[index]

            if time == sentence.startTime {
                return (index, sentence)
            }
            
            if time > sentence.startTime {
                
                let isLast = (index == sentences.count - 1)
                
                if isLast {
                    return (index, sentence)
                }
                
                continue
            }

            if index == 0 {
                return nil
            }
            
            let prevIndex = index - 1
            let prevSentence = sentences[prevIndex]
            
            return (prevIndex, prevSentence)
        }
        
        return nil
    }
}

