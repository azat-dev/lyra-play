//
//  CurrentPlayerStateDetailsViewModelFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 30.09.2022.
//

public protocol CurrentPlayerStateDetailsViewModelFactory {

    func make(delegate: CurrentPlayerStateDetailsViewModelDelegate) -> CurrentPlayerStateDetailsViewModel
}
