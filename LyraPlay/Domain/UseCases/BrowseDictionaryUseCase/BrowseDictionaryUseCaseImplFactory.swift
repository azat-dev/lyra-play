//
//  BrowseDictionaryUseCaseImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 30.08.2022.
//

import Foundation

public final class BrowseDictionaryUseCaseImplFactory: BrowseDictionaryUseCaseFactory {

    // MARK: - Properties

    private let dictionaryRepository: DictionaryRepository

    // MARK: - Initializers

    public init(dictionaryRepository: DictionaryRepository) {

        self.dictionaryRepository = dictionaryRepository
    }

    // MARK: - Methods

    public func make() -> BrowseDictionaryUseCase {

        return BrowseDictionaryUseCaseImpl(dictionaryRepository: dictionaryRepository)
    }
}
