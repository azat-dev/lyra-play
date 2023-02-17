//
//  LibraryFolderFlowModelFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 07.09.2022.
//

import Foundation

public protocol LibraryFolderFlowModelFactory {
    
    func make(folderId: UUID?) -> LibraryFolderFlowModel
}
