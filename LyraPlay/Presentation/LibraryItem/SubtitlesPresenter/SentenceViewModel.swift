//
//  SentenceViewModel.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 13.07.22.
//

import Foundation

public typealias RowId = Int

public typealias ToggleWordCallback = (_ rowId: RowId, _ range: Range<String.Index>) -> Void

// MARK: - Interfaces

public protocol SentenceViewModel {
    
    var id: RowId { get }
    
    var isActive: Observable<Bool> { get }
    
    var text: String { get }
    
    var toggleWord: ToggleWordCallback { get }
    
    var selectedWordRange: Observable<Range<String.Index>?> { get }
}

// MARK: - Implementations

public struct DefaultSentenceViewModel: SentenceViewModel {
    
    public var id: RowId
    
    public var isActive: Observable<Bool> = Observable(false)
    
    public var text: String
    
    public var toggleWord: ToggleWordCallback
    
    public var selectedWordRange: Observable<Range<String.Index>?> = Observable(nil)
    
    public var textComponents: [TextComponent] = []
}
