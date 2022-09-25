//
//  PlayMediaUseCaseFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 31.08.2022.
//

public protocol PlayMediaUseCaseFactory {

    func create() -> PlayMediaUseCase
}