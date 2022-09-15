//
//  ConfirmDialogViewModelImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 15.09.2022.
//

import Foundation

public final class ConfirmDialogViewModelImpl: ConfirmDialogViewModel {

    // MARK: - Properties

    private weak var delegate: ConfirmDialogViewModelDelegate?
    public var messageText: String = .init()
    public var confirmText: String = .init()
    public var cancelText: String = .init()

    // MARK: - Initializers

    public init(delegate: ConfirmDialogViewModelDelegate) {

        self.delegate = delegate
    }
}

// MARK: - Input Methods

extension ConfirmDialogViewModelImpl {

    public func confirm() {

        fatalError()
    }

    public func cancel() {

        fatalError()
    }
    
    public func dispose() {
        
        fatalError()
    }
}
