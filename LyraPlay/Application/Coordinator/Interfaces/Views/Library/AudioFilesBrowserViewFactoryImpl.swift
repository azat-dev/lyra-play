//
//  AudioFilesBrowserViewFactoryImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 26.08.22.
//

import Foundation

public final class AudioFilesBrowserViewFactoryImpl: AudioFilesBrowserViewFactory {
    
    public func create(viewModel: AudioFilesBrowserViewModel) -> AudioFilesBrowserView {
        
        return AudioFilesBrowserViewController(viewModel: viewModel)
    }
}
