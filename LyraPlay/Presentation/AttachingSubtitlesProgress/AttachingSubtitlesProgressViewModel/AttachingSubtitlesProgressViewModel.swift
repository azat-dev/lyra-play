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

public protocol AttachingSubtitlesProgressViewModelDelegate: AnyObject {
    
    func attachingSubtitlesProgressViewModelDidCancel()
    
    func attachingSubtitlesProgressViewModelDidFinish()
}

public protocol AttachingSubtitlesProgressViewModelInput: AnyObject {

    func cancel()
    
    func showSuccess(completion: @escaping () -> Void)
}

public protocol AttachingSubtitlesProgressViewModelOutput: AnyObject {

    var state: CurrentValueSubject<AttachingSubtitlesProgressState, Never> { get }
}

public protocol AttachingSubtitlesProgressViewModel: AttachingSubtitlesProgressViewModelOutput, AttachingSubtitlesProgressViewModelInput {}
