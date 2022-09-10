//
//  AttachingSubtitlesProgressViewModelImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 10.09.2022.
//

import Foundation

public final class AttachingSubtitlesProgressViewModelImplFactory: AttachingSubtitlesProgressViewModelFactory {

    // MARK: - Properties

    private let delegate: AttachingSubtitlesProgressViewModelDelegate

    // MARK: - Initializers

    public init(delegate: AttachingSubtitlesProgressViewModelDelegate) {

        self.delegate = delegate
    }

    // MARK: - Methods

    public func create() -> AttachingSubtitlesProgressViewModel {

        return AttachingSubtitlesProgressViewModelImpl(delegate: delegate)
    }
}