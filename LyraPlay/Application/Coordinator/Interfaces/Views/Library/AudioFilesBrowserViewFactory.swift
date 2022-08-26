//
//  AudioFilesBrowserViewFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 26.08.22.
//

import Foundation

public protocol AudioFilesBrowserViewFactory: AnyObject {
    
    func create(viewModel: AudioFilesBrowserViewModel) -> AudioFilesBrowserView
}
