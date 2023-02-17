//
//  AttachingSubtitlesProgressViewFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 10.09.2022.
//

public protocol AttachingSubtitlesProgressViewFactory {

    func make(viewModel: AttachingSubtitlesProgressViewModel) -> AttachingSubtitlesProgressViewController
}
