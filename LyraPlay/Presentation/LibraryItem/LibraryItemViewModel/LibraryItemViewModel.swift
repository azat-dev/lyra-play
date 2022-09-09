//
//  LibraryItemViewModel.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 05.09.2022.
//

import Foundation
import Combine

public protocol LibraryItemViewModelInput {

    func load() async

    func togglePlay() async

    func attachSubtitles(language: String) async
    
    func finish()
}

public protocol LibraryItemViewModelOutput {

    var isPlaying: Observable<Bool> { get }

    var info: Observable<LibraryItemInfoPresentation?> { get }

    var subtitlesPresenterViewModel: Observable<SubtitlesPresenterViewModel?> { get }
}

public protocol LibraryItemViewModel: LibraryItemViewModelOutput, LibraryItemViewModelInput {

}
