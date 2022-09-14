//
//  DictionaryListBrowserItemViewModel.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 14.09.2022.
//

import Foundation

public typealias PlaySoundCallback = (_ id: UUID) -> Void

public protocol DictionaryListBrowserItemViewModelInput {

    func playSound()
    
    mutating func setIsPlaying(_ value: Bool)
}

public protocol DictionaryListBrowserItemViewModelOutput {

    var id: UUID { get }

    var title: String { get }

    var description: String { get }

    var isSoundPlaying: Bool { get }
}

public protocol DictionaryListBrowserItemViewModel: DictionaryListBrowserItemViewModelOutput, DictionaryListBrowserItemViewModelInput {}
