//
//  AttachSubtitlesFlowModelFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 10.09.2022.
//

import Foundation

public protocol AttachSubtitlesFlowModelFactory {

    func create(mediaId: UUID, delegate: AttachSubtitlesFlowModelDelegate) -> AttachSubtitlesFlowModel
}
