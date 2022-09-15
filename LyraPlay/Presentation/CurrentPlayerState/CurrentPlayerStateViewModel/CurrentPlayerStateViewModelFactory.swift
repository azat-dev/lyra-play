//
//  CurrentPlayerStateViewModelFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 15.09.2022.
//

public protocol CurrentPlayerStateViewModelFactory {

    func create(delegate: CurrentPlayerStateViewModelDelegate) -> CurrentPlayerStateViewModel
}