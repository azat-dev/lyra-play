//
//  AttachSubtitlesFlowModel.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 10.09.2022.
//

import Foundation
import Combine

public protocol AttachSubtitlesFlowModelDelegate: AnyObject {
    
    func attachSubtitlesFlowDidCancel()
    
    func attachSubtitlesFlowDidStart(for mediaId: UUID)
    
    func attachSubtitlesFlowDidFinish(for mediaId: UUID)
    
    func attachSubtitlesFlowDidAttach(for mediaId: UUID)
}

public protocol AttachSubtitlesFlowModelInput: AnyObject {}

public protocol AttachSubtitlesFlowModelOutput: AnyObject {

    var subtitlesPickerViewModel: FilesPickerViewModel { get }
    
    var progressViewModel: CurrentValueSubject<AttachingSubtitlesProgressViewModel?, Never> { get }
}

public protocol AttachSubtitlesFlowModel: AttachSubtitlesFlowModelOutput, AttachSubtitlesFlowModelInput {}
