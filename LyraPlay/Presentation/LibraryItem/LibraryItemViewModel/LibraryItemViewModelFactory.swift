//
//  LibraryItemViewModelFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 05.09.2022.
//

import Foundation

public protocol LibraryItemViewModelFactory {

    func create(mediaId: UUID, coordinator: LibraryItemCoordinatorInput) -> LibraryItemViewModel
}
