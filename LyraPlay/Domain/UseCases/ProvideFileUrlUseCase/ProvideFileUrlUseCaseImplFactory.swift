//
//  ProvideFileUrlUseCaseImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 18.01.2023.
//

import Foundation

public final class ProvideFileUrlUseCaseImplFactory: ProvideFileUrlUseCaseFactory {

    // MARK: - Initializers

    public init() {}

    // MARK: - Methods

    public func create(callback: @escaping ProvideFileUrlUseCaseCallback) -> ProvideFileUrlUseCase {

        return ProvideFileUrlUseCaseImpl(callback: callback)
    }
}
