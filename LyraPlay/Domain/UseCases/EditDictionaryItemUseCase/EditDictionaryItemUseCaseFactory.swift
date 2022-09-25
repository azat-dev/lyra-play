//
//  EditDictionaryItemUseCaseFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 12.09.2022.
//

public protocol EditDictionaryItemUseCaseFactory {

    func create() -> EditDictionaryItemUseCase
}