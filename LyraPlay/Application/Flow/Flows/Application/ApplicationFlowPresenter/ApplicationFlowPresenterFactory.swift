//
//  ApplicationFlowPresenterFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 28.01.2023.
//

public protocol ApplicationFlowPresenterFactory {

    func make(for flowModel: ApplicationFlowModel) -> ApplicationFlowPresenter
}
