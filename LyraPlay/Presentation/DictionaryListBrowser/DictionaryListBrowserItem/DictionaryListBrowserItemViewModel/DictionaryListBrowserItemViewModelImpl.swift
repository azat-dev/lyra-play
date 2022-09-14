//
//  DictionaryListBrowserItemViewModelImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 14.09.2022.
//

import Foundation

public struct DictionaryListBrowserItemViewModelImpl: DictionaryListBrowserItemViewModel {

    public typealias PlaySoundCallback = (_ id: UUID) -> Void
    
    // MARK: - Properties

    public var id: UUID
    public var title: String
    public var description: String
    public var isSoundPlaying: Bool
    
    private let playSoundCallback: PlaySoundCallback

    // MARK: - Initializers

    public init(for item: BrowseListDictionaryItem, isPlaying: Bool, onPlaySound: @escaping PlaySoundCallback) {

        id = item.id
        title = item.originalText
        isSoundPlaying = isPlaying
        description = item.translatedText
        self.playSoundCallback = onPlaySound
    }
}

// MARK: - Input Methods

extension DictionaryListBrowserItemViewModelImpl {

    public func playSound() {

        playSoundCallback(id)
    }
    
    mutating public func setIsPlaying(_ value: Bool) {
        
        isSoundPlaying = value
    }
}
