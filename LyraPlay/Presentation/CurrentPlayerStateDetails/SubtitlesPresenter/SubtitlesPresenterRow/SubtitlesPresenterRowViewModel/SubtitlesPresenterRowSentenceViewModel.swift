//
//  SubtitlesPresenterRowViewModelSentence.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 31.03.23.
//

import Foundation
import Combine

public typealias ToggleWordCallback = (_ rowId: RowId, _ range: Range<String.Index>?) -> Void

// MARK: - Interfaces

public protocol SubtitlesPresenterRowSentenceViewModel {
    
    var text: String { get }
    
    var toggleWord: ToggleWordCallback { get }
    
    var dictionaryWords: CurrentValueSubject<[NSRange]?, Never> { get }
}
