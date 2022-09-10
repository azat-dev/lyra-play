//
//  AttachSubtitlesFlowPresenterFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 10.09.2022.
//

public protocol AttachSubtitlesFlowPresenterFactory {

    func create(for flowModel: AttachSubtitlesFlowModel) -> AttachSubtitlesFlowPresenter
}