//
//  AudioFilesBrowserViewModelFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 05.09.2022.
//

public protocol AudioFilesBrowserViewModelFactory {

    func create(delegate: AudioFilesBrowserViewModelDelegate) -> AudioFilesBrowserViewModel
}
