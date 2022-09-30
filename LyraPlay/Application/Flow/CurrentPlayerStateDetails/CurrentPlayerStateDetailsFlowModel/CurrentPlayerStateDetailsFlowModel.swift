//
//  CurrentPlayerStateDetailsFlowModel.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 30.09.2022.
//

import Foundation

public protocol CurrentPlayerStateDetailsFlowModelDelegate: AnyObject {
    
    func currentPlayerStateDetailsFlowModelDidDispose()
}


public protocol CurrentPlayerStateDetailsFlowModelInput: AnyObject {}

public protocol CurrentPlayerStateDetailsFlowModelOutput: AnyObject {

    var currentPlayerStateDetailsViewModel: CurrentPlayerStateDetailsViewModel { get }
}

public protocol CurrentPlayerStateDetailsFlowModel: CurrentPlayerStateDetailsFlowModelOutput, CurrentPlayerStateDetailsFlowModelInput {}
