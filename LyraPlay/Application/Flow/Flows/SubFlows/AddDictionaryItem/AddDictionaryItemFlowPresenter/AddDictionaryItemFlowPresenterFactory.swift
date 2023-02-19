//
//  AddDictionaryItemFlowPresenterFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 12.09.2022.
//

public protocol AddDictionaryItemFlowPresenterFactory {

    func make(for flowModel: AddDictionaryItemFlowModel) -> AddDictionaryItemFlowPresenter
}
