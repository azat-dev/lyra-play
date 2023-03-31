//
//  SubtitlesPresenterRowViewModelImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 31.03.23.
//

import Foundation
import Combine

public final class SubtitlesPresenterRowViewModelImpl: SubtitlesPresenterRowViewModel {
    
    // MARK: - Properties
    
    public var id: RowId
    
    public var isActive: CurrentValueSubject<Bool, Never>
    
    public var data: SubtitlesPresenterRowViewModelData
    
    // MARK: - Initializers
    
    public init(
        id: RowId,
        isActive: Bool = false,
        data: SubtitlesPresenterRowViewModelData
    ) {
        
        self.id = id
        self.data = data
        self.isActive = .init(isActive)
    }
    
    // MARK: - Methods
    
    public func activate() {

        isActive.value = true
    }
    
    public func deactivate() {

        isActive.value = false
    }
}
