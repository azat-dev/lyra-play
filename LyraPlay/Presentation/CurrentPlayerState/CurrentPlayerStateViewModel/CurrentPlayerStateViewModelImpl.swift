//
//  CurrentPlayerStateViewModelImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 15.09.2022.
//

import Foundation
import Combine

public final class CurrentPlayerStateViewModelImpl: CurrentPlayerStateViewModel {

    // MARK: - Properties

    private weak var delegate: CurrentPlayerStateViewModelDelegate?
    
    private let playMediaUseCase: PlayMediaWithTranslationsUseCase
    private let showMediaInfoUseCase: ShowMediaInfoUseCase
    public var state = CurrentValueSubject<CurrentPlayerStateViewModelState, Never>(.loading)

    // MARK: - Initializers

    public init(
        delegate: CurrentPlayerStateViewModelDelegate,
        playMediaUseCase: PlayMediaWithTranslationsUseCase,
        showMediaInfoUseCase: ShowMediaInfoUseCase
    ) {

        self.delegate = delegate
        self.playMediaUseCase = playMediaUseCase
        self.showMediaInfoUseCase = showMediaInfoUseCase
    }
}

// MARK: - Input Methods

extension CurrentPlayerStateViewModelImpl {

    public func open() {

        fatalError()
    }

    public func togglePlay() {

        fatalError()
    }
}

// MARK: - Output Methods

extension CurrentPlayerStateViewModelImpl {

}
