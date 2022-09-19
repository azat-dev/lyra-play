//
//  ImportMediaFilesFlowModelFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 10.09.2022.
//

import Foundation

public protocol ImportMediaFilesFlowModelFactory {

    func create(targetFolderId: UUID?, delegate: ImportMediaFilesFlowModelDelegate) -> ImportMediaFilesFlowModel
}
