//
//  LibraryFileFlowModel.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 08.09.2022.
//

import Foundation
import Combine

public protocol LibraryFileFlowModelInput: AnyObject {

    func runAttachSubtitlesFlow()
}

public protocol LibraryFileFlowModelDelegate: AnyObject {
    
    func libraryFileFlowDidDispose()
}

public protocol LibraryFileFlowModelOutput: AnyObject {

    var viewModel: LibraryItemViewModel { get }
    
    var attachSubtitlesFlow: CurrentValueSubject<AttachSubtitlesFlowModel?, Never> { get }
    
    var delegate: LibraryFileFlowModelDelegate? { get set }
}

public protocol LibraryFileFlowModel: LibraryFileFlowModelOutput, LibraryFileFlowModelInput {}
