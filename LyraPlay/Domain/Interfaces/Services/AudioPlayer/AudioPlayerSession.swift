//
//  AudioPlayerSession.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 01.09.2022.
//

import Foundation

public struct AudioPlayerSession: Equatable {

    // MARK: - Properties

    public let fileId: String

    // MARK: - Initializers

    public init(fileId: String) {

        self.fileId = fileId
    }
}
