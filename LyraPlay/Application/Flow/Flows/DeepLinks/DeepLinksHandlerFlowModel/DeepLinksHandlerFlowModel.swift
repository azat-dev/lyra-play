//
//  DeepLinksHandlerFlowModel.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 28.01.2023.
//

import Foundation

public protocol DeepLinksHandlerFlowModelInput: AnyObject {

    func handle(urls: [URL])
}

public protocol DeepLinksHandlerFlowModelOutput: AnyObject {

}

public protocol DeepLinksHandlerFlowModel: DeepLinksHandlerFlowModelOutput, DeepLinksHandlerFlowModelInput {

}
