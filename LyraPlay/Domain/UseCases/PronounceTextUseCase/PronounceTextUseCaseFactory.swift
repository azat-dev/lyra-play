//
//  PronounceTextUseCaseFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 13.09.2022.
//

public protocol PronounceTextUseCaseFactory {

    func make() -> PronounceTextUseCase
}
