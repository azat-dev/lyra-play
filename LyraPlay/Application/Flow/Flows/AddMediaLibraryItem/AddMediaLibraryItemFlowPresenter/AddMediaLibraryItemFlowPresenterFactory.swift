//
//  AddMediaLibraryItemFlowPresenterFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.09.2022.
//

public protocol AddMediaLibraryItemFlowPresenterFactory {

    func create(for flowModel: AddMediaLibraryItemFlowModel) -> AddMediaLibraryItemFlowPresenter
}