//
//  LibraryFlowModel.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 07.09.2022.
//

import Foundation
import Combine

public protocol LibraryFlowModelInput: AnyObject {}

public protocol LibraryFlowModelOutput: AnyObject {

    var folderId: UUID? { get }
    
    var listViewModel: MediaLibraryBrowserViewModel { get }
    
    var libraryItemFlow: CurrentValueSubject<LibraryItemFlowModel?, Never> { get }
    
    var addMediaLibraryItemFlow: CurrentValueSubject<AddMediaLibraryItemFlowModel?, Never> { get }
    
    var deleteMediaLibraryItemFlow: CurrentValueSubject<DeleteMediaLibraryItemFlowModel?, Never> { get }
}

public protocol LibraryFlowModel: LibraryFlowModelOutput, LibraryFlowModelInput {}
