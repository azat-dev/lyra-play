//
//  DictionaryListBrowserItemViewModelFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 14.09.2022.
//

public protocol DictionaryListBrowserItemViewModelFactory {

    func create(
        for item: BrowseListDictionaryItem,
        isPlaying: Bool,
        onPlaySound: @escaping PlaySoundCallback
    ) -> DictionaryListBrowserItemViewModel
}
