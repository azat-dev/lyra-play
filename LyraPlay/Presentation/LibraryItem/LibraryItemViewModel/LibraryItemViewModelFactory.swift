//
//  LibraryItemViewModelFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 05.09.2022.
//

import Foundation

public protocol LibraryItemViewModelFactory {

    func make(mediaId: UUID, delegate: LibraryItemViewModelDelegate) -> LibraryItemViewModel
}
