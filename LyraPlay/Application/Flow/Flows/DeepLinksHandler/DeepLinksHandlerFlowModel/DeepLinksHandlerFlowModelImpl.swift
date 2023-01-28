//
//  DeepLinksHandlerFlowModelImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 28.01.2023.
//

import Foundation

public final class DeepLinksHandlerFlowModelImpl: DeepLinksHandlerFlowModel {

    // MARK: - Properties

    private let mainFlowModel: MainFlowModel

    // MARK: - Initializers

    public init(mainFlowModel: MainFlowModel) {

        self.mainFlowModel = mainFlowModel
    }
}

// MARK: - Input Methods

extension DeepLinksHandlerFlowModelImpl {

    public func handle(url: URL) {

        fatalError()
    }
}

// MARK: - Output Methods

extension DeepLinksHandlerFlowModelImpl {

}