//
//  DictionaryListBrowserViewModelFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 05.09.2022.
//

public protocol DictionaryListBrowserViewModelFactory {

    func make(delegate: DictionaryListBrowserViewModelDelegate) -> DictionaryListBrowserViewModel
}
