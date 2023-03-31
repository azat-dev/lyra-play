//
//  SubtitlesPresenterRowViewModel.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 31.03.23.
//

import Foundation
import Combine

public typealias RowId = Int

public enum SubtitlesPresenterRowViewModelData {

    case empty
    
    case sentence(SubtitlesPresenterRowSentenceViewModel)
}

public protocol SubtitlesPresenterRowViewModel: AnyObject {

    // MARK: - Properties
    
    var id: RowId { get }
    
    var isActive: CurrentValueSubject<Bool, Never> { get }
    
    var data: SubtitlesPresenterRowViewModelData { get }
    
    // MARK: - Methods
    
    func activate()
    
    func deactivate()
}
