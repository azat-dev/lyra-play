//
//  AttachSubtitlesFlowModelFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 10.09.2022.
//

public protocol AttachSubtitlesFlowModelFactory {

    func create(allowedDocumentTypes: [String]) -> AttachSubtitlesFlowModel
}