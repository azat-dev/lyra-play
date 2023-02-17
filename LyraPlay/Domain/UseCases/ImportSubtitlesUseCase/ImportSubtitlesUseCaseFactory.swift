//
//  ImportSubtitlesUseCaseFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 30.08.2022.
//

public protocol ImportSubtitlesUseCaseFactory {
    
    func make() -> ImportSubtitlesUseCase
}
