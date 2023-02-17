//
//  CurrentPlayerStateDetailsViewFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 30.09.2022.
//

public protocol CurrentPlayerStateDetailsViewFactory {

    func make(viewModel: CurrentPlayerStateDetailsViewModel) -> CurrentPlayerStateDetailsViewController
}
