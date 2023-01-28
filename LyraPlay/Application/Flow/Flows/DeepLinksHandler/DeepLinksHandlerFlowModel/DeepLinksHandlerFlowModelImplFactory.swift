//
//  DeepLinksHandlerFlowModelImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 28.01.2023.
//

import Foundation

public final class DeepLinksHandlerFlowModelImplFactory: DeepLinksHandlerFlowModelFactory {

    // MARK: - Initializers

    public init() {}

    // MARK: - Methods

    public func create(mainFlowModel: MainFlowModel) -> DeepLinksHandlerFlowModel {

        return DeepLinksHandlerFlowModelImpl(mainFlowModel: mainFlowModel)
    }
}