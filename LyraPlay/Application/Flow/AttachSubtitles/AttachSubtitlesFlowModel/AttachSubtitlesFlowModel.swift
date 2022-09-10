//
//  AttachSubtitlesFlowModel.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 10.09.2022.
//

import Foundation

public protocol AttachSubtitlesFlowModelInput: AnyObject {

}

public protocol AttachSubtitlesFlowModelOutput: AnyObject {

    var subtitlesPickerViewModel: SubtitlesPickerViewModel { get }
}

public protocol AttachSubtitlesFlowModel: AttachSubtitlesFlowModelOutput, AttachSubtitlesFlowModelInput {}
