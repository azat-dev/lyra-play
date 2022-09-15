//
//  DeleteMediaLibraryItemFlowPresenterFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 15.09.2022.
//

public protocol DeleteMediaLibraryItemFlowPresenterFactory {

    func create(for flowModel: DeleteMediaLibraryItemFlowModel) -> DeleteMediaLibraryItemFlowPresenter
}