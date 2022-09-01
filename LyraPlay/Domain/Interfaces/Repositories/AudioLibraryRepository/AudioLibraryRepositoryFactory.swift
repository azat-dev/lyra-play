//
//  AudioLibraryRepositoryFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 01.09.2022.
//

public protocol AudioLibraryRepositoryFactory {
    
    func create() -> AudioLibraryRepository
}
