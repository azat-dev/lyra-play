//
//  ProvideFileUrlUseCaseImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 18.01.2023.
//

import Foundation

public final class ProvideFileUrlUseCaseImpl: ProvideFileUrlUseCase {

    // MARK: - Properties

    private let callback: ProvideFileUrlUseCaseCallback

    // MARK: - Initializers

    public init(callback: @escaping ProvideFileUrlUseCaseCallback) {

        self.callback = callback
    }
}

// MARK: - Output Methods

extension ProvideFileUrlUseCaseImpl {

    public func provideFileUrl() -> Result<URL, Error> {
        return .success(callback())
    }
}
