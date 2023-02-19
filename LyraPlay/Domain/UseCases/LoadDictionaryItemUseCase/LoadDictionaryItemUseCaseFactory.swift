//
//  LoadDictionaryItemUseCaseFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 11.09.2022.
//

public protocol LoadDictionaryItemUseCaseFactory {

    func make() -> LoadDictionaryItemUseCase
}
