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

    private let provideFileUrlUseCase: ProvideFileUrlUseCase

    // MARK: - Initializers

    public init(
        provideFileUrlUseCase: ProvideFileUrlUseCase,
        delegate: FileSharingViewModelDelegate
    ) {

        self.provideFileUrlUseCase = provideFileUrlUseCase
        self.delegate = delegate
    }
}

// MARK: - Input Methods

extension FileSharingViewModelImpl {

    public func dispose() {

        delegate?.fileSharingViewModelDidDispose()
    }
}

// MARK: - Output Methods

extension FileSharingViewModelImpl {

    public func getFile() -> URL? {

        let result = provideFileUrlUseCase.provideFileUrl()

        guard case .success(let url) = result else {
            delegate?.fileSharingViewModelDidDispose()
            return nil
        }
        
        return url
    }
}
