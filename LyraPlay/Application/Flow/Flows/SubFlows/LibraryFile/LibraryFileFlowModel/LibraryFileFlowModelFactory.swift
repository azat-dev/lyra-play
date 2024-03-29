//
//  LibraryFileFlowModelFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 08.09.2022.
//

import Foundation

public protocol LibraryFileFlowModelFactory {

    func make(for mediaId: UUID, delegate: LibraryFileFlowModelDelegate) -> LibraryFileFlowModel
}
