//
//  LibraryItemViewFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 05.09.2022.
//

public protocol LibraryItemViewFactory {

    func make(viewModel: LibraryItemViewModel) -> LibraryItemViewController
}
