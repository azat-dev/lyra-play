//
//  CurrentPlayerStateDetailsViewModelImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 30.09.2022.
//

import Foundation
import Combine

public final class CurrentPlayerStateDetailsViewModelImpl: CurrentPlayerStateDetailsViewModel {

    // MARK: - Properties

    private weak var delegate: CurrentPlayerStateDetailsViewModelDelegate? 

    private let playMediaUseCase: PlayMediaWithInfoUseCase

    public let state = CurrentValueSubject<CurrentPlayerStateDetailsViewModelState, Never>(.loading)

    // MARK: - Initializers

    public init(
        delegate: CurrentPlayerStateDetailsViewModelDelegate,
        playMediaUseCase: PlayMediaWithInfoUseCase
    ) {

        self.delegate = delegate
        self.playMediaUseCase = playMediaUseCase
    }
}

// MARK: - Input Methods

extension CurrentPlayerStateDetailsViewModelImpl {

    public func togglePlay() {

        fatalError()
    }

    public func dispose() {

        delegate?.currentPlayerStateDetailsViewModelDidDispose()
    }
}

// MARK: - Output Methods

extension CurrentPlayerStateDetailsViewModelImpl {

}
