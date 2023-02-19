//
//  AttachingSubtitlesProgressViewModelFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 10.09.2022.
//

public protocol AttachingSubtitlesProgressViewModelFactory {

    func make(delegate: AttachingSubtitlesProgressViewModelDelegate) -> AttachingSubtitlesProgressViewModel
}
