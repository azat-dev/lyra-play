//
//  PronounceTextUseCase.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 13.09.2022.
//

import Foundation
import Combine

public enum PronounceTextUseCaseState: Equatable {

    case loading
    case playing
    case finished
}

public protocol PronounceTextUseCaseInput: AnyObject {

    func pronounce(
        text: String,
        language: String
    ) -> AsyncThrowingStream<PronounceTextUseCaseState, Error>
}

public protocol PronounceTextUseCaseOutput: AnyObject {

    var state: CurrentValueSubject<PronounceTextUseCaseState, Never> { get }
}

public protocol PronounceTextUseCase: PronounceTextUseCaseOutput, PronounceTextUseCaseInput {}
