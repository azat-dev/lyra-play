//
//  ProvideFileForSharingUseCaseFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 18.01.2023.
//

import Foundation

public typealias ProvideFileForSharingUseCaseCallback = () -> URL

public protocol ProvideFileForSharingUseCaseFactory {

    func make() -> ProvideFileForSharingUseCase
}
