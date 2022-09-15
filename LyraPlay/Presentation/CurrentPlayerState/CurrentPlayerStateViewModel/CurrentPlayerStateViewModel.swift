//
//  CurrentPlayerStateViewModel.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 15.09.2022.
//

import Foundation
import Combine

public protocol CurrentPlayerStateViewModelDelegate: AnyObject {
    
    func currentPlayerStateViewModelDidOpen()
}

public enum CurrentPlayerStateViewModelState {

    case loading
    case notActive
    case active(mediaInfo: MediaInfo, state: PlayerState)
}

public protocol CurrentPlayerStateViewModelInput: AnyObject {

    func open()

    func togglePlay()
}

public protocol CurrentPlayerStateViewModelOutput: AnyObject {

    var state: CurrentValueSubject<CurrentPlayerStateViewModelState, Never> { get }
}

public protocol CurrentPlayerStateViewModel: CurrentPlayerStateViewModelOutput, CurrentPlayerStateViewModelInput {

}
