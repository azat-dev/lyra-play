//
//  DictionaryListBrowserViewFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 05.09.2022.
//

public protocol DictionaryListBrowserViewFactory {

    func create(viewModel: DictionaryListBrowserViewModel) -> DictionaryListBrowserViewController
}
