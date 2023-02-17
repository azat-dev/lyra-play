//
//  CurrentPlayerStateDetailsFlowModelFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 30.09.2022.
//

public protocol CurrentPlayerStateDetailsFlowModelFactory {

    func make(delegate: CurrentPlayerStateDetailsFlowModelDelegate) -> CurrentPlayerStateDetailsFlowModel
}
