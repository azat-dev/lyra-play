//
//  AttachingSubtitlesProgressViewModel.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 10.09.2022.
//

import Foundation
import Combine

public enum AttachingSubtitlesProgressState {

    case processing
    case succeded
}

public protocol AttachingSubtitlesProgressViewModelDelegate: AnyCancellable {
    
    func cancel()
}

public protocol AttachingSubtitlesProgressViewModelInput: AnyObject {

    func cancel()
}

public protocol AttachingSubtitlesProgressViewModelOutput: AnyObject {

    var state: CurrentValueSubject<AttachingSubtitlesProgressState, Never> { get }
}

public protocol AttachingSubtitlesProgressViewModel: AttachingSubtitlesProgressViewModelOutput, AttachingSubtitlesProgressViewModelInput {}
