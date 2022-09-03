//
//  AudioFilesBrowserViewFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 01.09.2022.
//

public protocol AudioFilesBrowserViewFactory: PresentableViewFactory
    where ViewModel: AudioFilesBrowserViewModel, View: AudioFilesBrowserView {}
