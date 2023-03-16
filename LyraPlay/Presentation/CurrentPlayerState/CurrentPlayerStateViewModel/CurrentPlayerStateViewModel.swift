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

public enum PlayerState: Equatable, CaseIterable {
    
    case playing
    case stopped
    case paused
}

public enum CurrentPlayerStateViewModelState {

    case loading
    case notActive
    case active(
        mediaInfo: MediaInfo,
        state: CurrentValueSubject<PlayerState, Never>
    )
}

extension CurrentPlayerStateViewModelState {
    
    public var mediaInfo: MediaInfo? {
        
        switch self {
            
        case .notActive, .loading:
            return nil

        case .active(let mediaInfo, _):
            return mediaInfo
        }
    }
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
