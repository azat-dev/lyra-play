//
//  ApplicationFlowModel.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 28.01.2023.
//

import Foundation
import Combine

public protocol ApplicationFlowModelInput: AnyObject {

}

public protocol ApplicationFlowModelOutput: AnyObject {

    var mainFlowModel: MainFlowModel { get }
}

public protocol ApplicationFlowModel: ApplicationFlowModelOutput, ApplicationFlowModelInput {

}
