//
//  ImportMediaFilesFlowModelFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 10.09.2022.
//

public protocol ImportMediaFilesFlowModelFactory {

    func create(delegate: ImportMediaFilesFlowModelDelegate) -> ImportMediaFilesFlowModel
}
