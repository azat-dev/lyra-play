//
//  LibraryFlowModel.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 07.09.2022.
//

import Foundation
import Combine

public protocol LibraryFlowModelInput: AnyObject {

}

public protocol LibraryFlowModelOutput: AnyObject {

    var listViewModel: AudioFilesBrowserViewModel { get }
    
    var libraryItemFlow: CurrentValueSubject<LibraryItemFlowModel?, Never> { get }
    
    var importMediaFilesFlow: CurrentValueSubject<ImportMediaFilesFlowModel?, Never> { get }
}

public protocol LibraryFlowModel: LibraryFlowModelOutput, LibraryFlowModelInput {}
