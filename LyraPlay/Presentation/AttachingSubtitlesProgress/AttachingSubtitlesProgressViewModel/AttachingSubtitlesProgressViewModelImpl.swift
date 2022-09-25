//
//  AttachingSubtitlesProgressViewModelImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 10.09.2022.
//

import Foundation
import Combine

public final class AttachingSubtitlesProgressViewModelImpl: AttachingSubtitlesProgressViewModel {

    // MARK: - Properties

    private weak var delegate: AttachingSubtitlesProgressViewModelDelegate?

    public var state = CurrentValueSubject<AttachingSubtitlesProgressState, Never>(.processing)

    // MARK: - Initializers

    public init(delegate: AttachingSubtitlesProgressViewModelDelegate) {

        self.delegate = delegate
    }
}

// MARK: - Input Methods

extension AttachingSubtitlesProgressViewModelImpl {

    public func cancel() {

        delegate?.attachingSubtitlesProgressViewModelDidCancel()
    }
    
    public func finish() {
        
        delegate?.attachingSubtitlesProgressViewModelDidFinish()
    }
    
    public func showSuccess(completion: @escaping () -> Void) {
        
        state.value = .succeded
        
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 0.3) {
            
            self.delegate?.attachingSubtitlesProgressViewModelDidFinish()
        }
    }
}
