//
//  SubtitlesPresenterRowViewModel.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 13.07.22.
//

import Foundation

public typealias RowId = Int

public typealias ToggleWordCallback = (_ rowId: RowId, _ range: Range<String.Index>?) -> Void

// MARK: - Interfaces

public protocol SubtitlesPresenterRowViewModelSentenceData {
    
    var text: String { get }
    
    var toggleWord: ToggleWordCallback { get }
    
    var selectedWordRange: Observable<Range<String.Index>?> { get }
}

public enum SubtitlesPresenterRowViewModelData {

    case empty
    
    case sentence(SubtitlesPresenterRowViewModelSentenceData)
}

public protocol SubtitlesPresenterRowViewModelDelegate: AnyObject {
    
    func subtitlesPresenterRowViewModelDidChange(isActive: Bool)
}

public protocol SubtitlesPresenterRowViewModel: AnyObject {

    // MARK: - Properties
    
    var id: RowId { get }
    
    var isActive: Bool { get }
    
    var data: SubtitlesPresenterRowViewModelData { get }
    
    var delegateChanges: SubtitlesPresenterRowViewModelDelegate? { get set }
    
    // MARK: - Methods
    
    func activate()
    
    func deactivate()
}

// MARK: - Implementations

public struct SubtitlesPresenterRowViewModelSentenceDataImpl: SubtitlesPresenterRowViewModelSentenceData {
    
    public var text: String
    
    public var toggleWord: ToggleWordCallback
    
    public var selectedWordRange: Observable<Range<String.Index>?> = Observable(nil)
    
    public var textComponents: [TextComponent] = []
}

public final class SubtitlesPresenterRowViewModelImpl: SubtitlesPresenterRowViewModel {
    
    // MARK: - Properties
    
    public var id: RowId
    
    public var isActive: Bool = false
    
    public var data: SubtitlesPresenterRowViewModelData
    
    public weak var delegateChanges: SubtitlesPresenterRowViewModelDelegate?
    
    // MARK: - Initializers
    
    public init(
        id: RowId,
        isActive: Bool = false,
        data: SubtitlesPresenterRowViewModelData,
        delegateChanges: SubtitlesPresenterRowViewModelDelegate?
    ) {
        
        self.id = id
        self.isActive = isActive
        self.data = data
        self.delegateChanges = delegateChanges
    }
    
    // MARK: - Methods
    
    public func activate() {

        isActive = true
        delegateChanges?.subtitlesPresenterRowViewModelDidChange(isActive: isActive)
    }
    
    public func deactivate() {

        isActive = false
        delegateChanges?.subtitlesPresenterRowViewModelDidChange(isActive: isActive)
    }
}
