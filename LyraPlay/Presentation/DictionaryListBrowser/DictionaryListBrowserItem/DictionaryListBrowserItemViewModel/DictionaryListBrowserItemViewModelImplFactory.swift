//
//  DictionaryListBrowserItemViewModelImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 14.09.2022.
//

import Foundation

public final class DictionaryListBrowserItemViewModelImplFactory: DictionaryListBrowserItemViewModelFactory {

    // MARK: - Initializers

    public init() {}

    // MARK: - Methods

    public func create(
        for item: BrowseListDictionaryItem,
        isPlaying: Bool,
        onPlaySound: @escaping PlaySoundCallback
    ) -> DictionaryListBrowserItemViewModel {

        return DictionaryListBrowserItemViewModelImpl(
            for: item,
            isPlaying: isPlaying,
            onPlaySound: onPlaySound
        )
    }
}
