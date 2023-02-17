//
//  CurrentPlayerStateDetailsFlowModelImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 30.09.2022.
//

import Foundation

public final class CurrentPlayerStateDetailsFlowModelImpl: CurrentPlayerStateDetailsFlowModel {
    
    // MARK: - Properties
    
    private let currentPlayerStateDetailsViewModelFactory: CurrentPlayerStateDetailsViewModelFactory
    
    private weak var delegate: CurrentPlayerStateDetailsFlowModelDelegate?
    
    public lazy var currentPlayerStateDetailsViewModel: CurrentPlayerStateDetailsViewModel = {
        
        return self.currentPlayerStateDetailsViewModelFactory.make(delegate: self)
    } ()
    
    // MARK: - Initializers
    
    public init(
        delegate: CurrentPlayerStateDetailsFlowModelDelegate,
        currentPlayerStateDetailsViewModelFactory: CurrentPlayerStateDetailsViewModelFactory
    ) {
        
        self.delegate = delegate
        self.currentPlayerStateDetailsViewModelFactory = currentPlayerStateDetailsViewModelFactory
    }
}

extension CurrentPlayerStateDetailsFlowModelImpl: CurrentPlayerStateDetailsViewModelDelegate {
    
    public func currentPlayerStateDetailsViewModelDidDispose() {
        
        self.delegate?.currentPlayerStateDetailsFlowModelDidDispose()
    }
}

// MARK: - Input Methods

extension CurrentPlayerStateDetailsFlowModelImpl {}

// MARK: - Output Methods

extension CurrentPlayerStateDetailsFlowModelImpl {}
