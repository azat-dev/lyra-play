//
//  LibraryFolderFlowModel.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 07.09.2022.
//

import Foundation
import Combine

public enum LibraryItemFlowModel {
    
    case file(LibraryFileFlowModel)
}


public protocol LibraryFolderFlowModelInput: AnyObject {}

public protocol LibraryFolderFlowModelOutput: AnyObject {

    var folderId: UUID? { get }
    
    var listViewModel: MediaLibraryBrowserViewModel { get }
    
    var libraryItemFlow: CurrentValueSubject<LibraryItemFlowModel?, Never> { get }
    
    var addMediaLibraryItemFlow: CurrentValueSubject<AddMediaLibraryItemFlowModel?, Never> { get }
    
    var deleteMediaLibraryItemFlow: CurrentValueSubject<DeleteMediaLibraryItemFlowModel?, Never> { get }
    
    func runOpenLibraryItemFlow(itemId: UUID)
    
    func runAddMediaLibratyItemsFlow(targetFolderId: UUID?, filesUrls: [URL]?)
}

public protocol LibraryFolderFlowModel: LibraryFolderFlowModelOutput, LibraryFolderFlowModelInput {}
