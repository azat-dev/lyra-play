//
//  LibraryCoordinator.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 26.08.22.
//

import Foundation

public protocol LibraryCoordinatorInput: AnyObject {
    
    func runImportMediaFilesFlow(completion: @escaping (_ urls: [URL]?) -> Void)
    
    func runOpenLibraryItemFlow(mediaId: UUID)
}

public protocol LibraryCoordinator: BaseCoordinator, LibraryCoordinatorInput {
    
    func start(at: StackPresentationContainer)
}
