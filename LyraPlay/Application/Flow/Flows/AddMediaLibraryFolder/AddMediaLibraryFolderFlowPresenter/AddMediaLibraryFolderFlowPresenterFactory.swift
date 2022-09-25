//
//  AddMediaLibraryFolderFlowPresenterFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 20.09.2022.
//

public protocol AddMediaLibraryFolderFlowPresenterFactory {

    func create(for flowModel: AddMediaLibraryFolderFlowModel) -> AddMediaLibraryFolderFlowPresenter
}