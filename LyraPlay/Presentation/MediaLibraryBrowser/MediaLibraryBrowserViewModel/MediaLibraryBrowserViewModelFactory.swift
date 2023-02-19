//
//  MediaLibraryBrowserViewModelFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 05.09.2022.
//

import Foundation

public protocol MediaLibraryBrowserViewModelFactory {

    func make(folderId: UUID?, delegate: MediaLibraryBrowserViewModelDelegate) -> MediaLibraryBrowserViewModel
}
