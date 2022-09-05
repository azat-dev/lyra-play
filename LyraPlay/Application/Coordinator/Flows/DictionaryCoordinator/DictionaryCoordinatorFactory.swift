//
//  DictionaryCoordinatorFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 05.09.2022.
//

public protocol DictionaryCoordinatorFactory {

    func create() -> DictionaryCoordinator
}