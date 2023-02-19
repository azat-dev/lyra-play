//
//  AttachSubtitlesFlowModelFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 10.09.2022.
//

import Foundation

public protocol AttachSubtitlesFlowModelFactory {

    func make(mediaId: UUID, delegate: AttachSubtitlesFlowModelDelegate) -> AttachSubtitlesFlowModel
}
