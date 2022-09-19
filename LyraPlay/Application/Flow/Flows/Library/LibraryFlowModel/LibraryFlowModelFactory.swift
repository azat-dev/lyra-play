//
//  LibraryFlowModelFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 07.09.2022.
//

import Foundation

public protocol LibraryFlowModelFactory {
    
    func create(folderId: UUID?) -> LibraryFlowModel
}
