//
//  AddMediaLibraryItemFlowPresenterFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.09.2022.
//

public protocol AddMediaLibraryItemFlowPresenterFactory {

    func make(for flowModel: AddMediaLibraryItemFlowModel) -> AddMediaLibraryItemFlowPresenter
}
