//
//  LibraryFolderFlowModel.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 07.09.2022.
//

import Foundation
import Combine

public protocol LibraryFolderFlowModelInput: AnyObject {}

public protocol LibraryFolderFlowModelOutput: AnyObject {

    var folderId: UUID? { get }
    
    var listViewModel: MediaLibraryBrowserViewModel { get }
    
    var libraryFileFlow: CurrentValueSubject<LibraryFileFlowModel?, Never> { get }
    
    var addMediaLibraryItemFlow: CurrentValueSubject<AddMediaLibraryItemFlowModel?, Never> { get }
    
    var deleteMediaLibraryItemFlow: CurrentValueSubject<DeleteMediaLibraryItemFlowModel?, Never> { get }
}

public protocol LibraryFolderFlowModel: LibraryFolderFlowModelOutput, LibraryFolderFlowModelInput {}
