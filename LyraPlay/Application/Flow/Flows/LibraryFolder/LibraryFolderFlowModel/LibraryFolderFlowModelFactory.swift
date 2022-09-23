//
//  LibraryFolderFlowModelFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 08.09.2022.
//

import Foundation

public protocol LibraryFolderFlowModelFactory {

    func create(for mediaId: UUID, delegate: LibraryFolderFlowModelDelegate) -> LibraryFolderFlowModel
}
