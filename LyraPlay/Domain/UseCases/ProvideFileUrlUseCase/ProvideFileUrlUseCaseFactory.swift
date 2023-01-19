//
//  ProvideFileUrlUseCaseFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 18.01.2023.
//

import Foundation

public typealias ProvideFileUrlUseCaseCallback = () -> URL

public protocol ProvideFileUrlUseCaseFactory {

    func create(callback: @escaping ProvideFileUrlUseCaseCallback) -> ProvideFileUrlUseCase
}
