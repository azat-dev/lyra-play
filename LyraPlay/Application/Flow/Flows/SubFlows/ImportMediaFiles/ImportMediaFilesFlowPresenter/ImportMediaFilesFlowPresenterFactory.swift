//
//  ImportMediaFilesFlowPresenterFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 10.09.2022.
//

public protocol ImportMediaFilesFlowPresenterFactory {

    func create(for flowModel: ImportMediaFilesFlowModel) -> ImportMediaFilesFlowPresenter
}