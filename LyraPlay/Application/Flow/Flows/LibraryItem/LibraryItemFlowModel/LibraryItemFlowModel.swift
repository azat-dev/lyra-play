//
//  LibraryItemFlowModel.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 08.09.2022.
//

import Foundation
import Combine

public protocol LibraryItemFlowModelInput: AnyObject {

    func runAttachSubtitlesFlow()
}

public protocol LibraryItemFlowModelDelegate: AnyObject {
    
    func libraryItemFlowDidDispose()
}

public protocol LibraryItemFlowModelOutput: AnyObject {

    var viewModel: LibraryItemViewModel { get }
    
    var attachSubtitlesFlow: CurrentValueSubject<AttachSubtitlesFlowModel?, Never> { get }
    
    var delegate: LibraryItemFlowModelDelegate? { get set }
}

public protocol LibraryItemFlowModel: LibraryItemFlowModelOutput, LibraryItemFlowModelInput {

}
