//
//  LibraryItemFlowModelFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 08.09.2022.
//

import Foundation

public protocol LibraryItemFlowModelFactory {

    func create(for mediaId: UUID) -> LibraryItemFlowModel
}
