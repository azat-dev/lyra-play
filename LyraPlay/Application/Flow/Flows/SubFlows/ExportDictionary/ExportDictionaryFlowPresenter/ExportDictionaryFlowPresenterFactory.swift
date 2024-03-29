//
//  ExportDictionaryFlowPresenterFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.01.2023.
//

public protocol ExportDictionaryFlowPresenterFactory {

    func make(for flowModel: ExportDictionaryFlowModel) -> ExportDictionaryFlowPresenter
}
