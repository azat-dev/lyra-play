//
//  CurrentPlayerStateDetailsFlowPresenterFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 30.09.2022.
//

public protocol CurrentPlayerStateDetailsFlowPresenterFactory {

    func create(for flowModel: CurrentPlayerStateDetailsFlowModel) -> CurrentPlayerStateDetailsFlowPresenter
}