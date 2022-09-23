//
//  LibraryFolderFlowModel.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 08.09.2022.
//

import Foundation
import Combine

public protocol LibraryFolderFlowModelInput: AnyObject {

    func runAttachSubtitlesFlow()
}

public protocol LibraryFolderFlowModelDelegate: AnyObject {
    
    func libraryFolderFlowDidDispose()
}

public protocol LibraryFolderFlowModelOutput: AnyObject {

    var viewModel: LibraryItemViewModel { get }
    
    var attachSubtitlesFlow: CurrentValueSubject<AttachSubtitlesFlowModel?, Never> { get }
    
    var delegate: LibraryFolderFlowModelDelegate? { get set }
}

public protocol LibraryFolderFlowModel: LibraryFolderFlowModelOutput, LibraryFolderFlowModelInput {}
