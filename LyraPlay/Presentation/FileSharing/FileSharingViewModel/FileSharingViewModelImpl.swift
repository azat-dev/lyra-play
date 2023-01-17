//
//  FileSharingViewModelImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 17.01.2023.
//

import Foundation

public final class FileSharingViewModelImpl: FileSharingViewModel {

    // MARK: - Properties

    private weak var delegate: FileSharingViewModelDelegate? 

    public let url: URL

    // MARK: - Initializers

    public init(
        url: URL,
        delegate: FileSharingViewModelDelegate
    ) {

        self.url = url
        self.delegate = delegate
    }
}

// MARK: - Input Methods

extension FileSharingViewModelImpl {

    public func dispose() {

        fatalError()
    }
}

// MARK: - Output Methods

extension FileSharingViewModelImpl {

}
