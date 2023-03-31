//
//  SubtitlesPresenterRowViewModel.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 13.07.22.
//

import Foundation
import Combine

// MARK: - Implementations

public struct SubtitlesPresenterRowViewModelSentenceDataImpl: SubtitlesPresenterRowSentenceViewModel {
    
    // MARK: - Properties
    
    public let text: String
    
    public let toggleWord: ToggleWordCallback
    
    public let dictionaryWords: CurrentValueSubject<[NSRange]?, Never>
    
    public let textComponents: [TextComponent] = []
    
    // MARK: - Initializers
    
    public init(
        text: String,
        toggleWord: @escaping ToggleWordCallback,
        dictionaryWords: [NSRange]?
    ) {
        self.text = text
        self.toggleWord = toggleWord
        self.dictionaryWords = .init(dictionaryWords)
    }
}

