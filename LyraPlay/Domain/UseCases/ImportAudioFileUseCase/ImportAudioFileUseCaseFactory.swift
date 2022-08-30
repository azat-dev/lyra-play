//
//  ImportAudioFileUseCaseFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 30.08.2022.
//

public protocol ImportAudioFileUseCaseFactory {

    func create() -> ImportAudioFileUseCase
}
