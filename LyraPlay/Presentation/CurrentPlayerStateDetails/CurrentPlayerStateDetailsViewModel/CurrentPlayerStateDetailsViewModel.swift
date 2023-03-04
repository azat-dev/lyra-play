//
//  CurrentPlayerStateDetailsViewModel.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 30.09.2022.
//

import Foundation
import Combine

public protocol CurrentPlayerStateDetailsViewModelDelegate: AnyObject {
    
    func currentPlayerStateDetailsViewModelDidDispose()
}

public enum CurrentPlayerStateDetailsViewModelState {

    case loading
    case notActive
    case active(data: CurrentPlayerStateDetailsViewModelPresentation)
}

public protocol CurrentPlayerStateDetailsViewModelInput: AnyObject {

    func togglePlay()

    func dispose()
}

public protocol CurrentPlayerStateDetailsViewModelOutput: AnyObject {

    var state: CurrentValueSubject<CurrentPlayerStateDetailsViewModelState, Never> { get }
    
    var currentTime: Float { get }
    
    var duration: Float { get }
}

public protocol CurrentPlayerStateDetailsViewModel: CurrentPlayerStateDetailsViewModelOutput, CurrentPlayerStateDetailsViewModelInput {}
