//
//  ProvideFileForSharingUseCase.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 18.01.2023.
//

import Foundation

public protocol ProvideFileForSharingUseCase: AnyObject {
    
    func provideFile() -> Data?
}
