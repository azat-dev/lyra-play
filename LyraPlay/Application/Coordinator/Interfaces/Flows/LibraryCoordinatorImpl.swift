//
//  LibraryCoordinatorImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 26.08.22.
//

import Foundation

public final class LibraryCoordinatorImpl: LibraryCoordinator {
    
    public init() {
        
    }
}

// MARK: - Input Methods

extension LibraryCoordinatorImpl {
    
    public func runImportMediaFilesFlow(completion: @escaping ([URL]?) -> Void) {
        fatalError()
    }
    
    public func runOpenLibraryItemFlow(mediaId: UUID) {
        fatalError()
    }
}
