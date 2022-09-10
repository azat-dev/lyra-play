//
//  AttachingSubtitlesProgressViewModelImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 10.09.2022.
//

import Foundation

public final class AttachingSubtitlesProgressViewModelImplFactory: AttachingSubtitlesProgressViewModelFactory {

    // MARK: - Initializers

    public init() {}

    // MARK: - Methods

    public func create(delegate: AttachingSubtitlesProgressViewModelDelegate) -> AttachingSubtitlesProgressViewModel {

        return AttachingSubtitlesProgressViewModelImpl(delegate: delegate)
    }
}
