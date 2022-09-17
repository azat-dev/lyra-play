//
//  DictionaryListBrowserItemViewModelImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 14.09.2022.
//

import Foundation

public struct DictionaryListBrowserItemViewModelImpl: DictionaryListBrowserItemViewModel {

    // MARK: - Properties

    public var id: UUID
    public var title: String
    public var description: String
    public var isSoundPlaying: Bool
    
    private weak var delegate: DictionaryListBrowserItemViewModelDelegate?

    // MARK: - Initializers

    public init(for item: BrowseListDictionaryItem, isPlaying: Bool, delegate: DictionaryListBrowserItemViewModelDelegate) {

        id = item.id
        title = item.originalText
        isSoundPlaying = isPlaying
        description = item.translatedText
        self.delegate = delegate
    }
}

// MARK: - Input Methods

extension DictionaryListBrowserItemViewModelImpl {

    public func playSound() {

        delegate?.dictionaryListBrowserItemViewModelDidPlay(itemId: id)
    }
    
    mutating public func setIsPlaying(_ value: Bool) {
        
        isSoundPlaying = value
    }
}
