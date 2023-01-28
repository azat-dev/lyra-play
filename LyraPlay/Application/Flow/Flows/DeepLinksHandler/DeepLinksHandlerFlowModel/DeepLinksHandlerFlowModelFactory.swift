//
//  DeepLinksHandlerFlowModelFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 28.01.2023.
//

public protocol DeepLinksHandlerFlowModelFactory {

    func create(mainFlowModel: MainFlowModel) -> DeepLinksHandlerFlowModel
}