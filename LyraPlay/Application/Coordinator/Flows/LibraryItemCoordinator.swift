//
//  LibraryItemCoordinator.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 27.08.22.
//

import Foundation

public protocol LibraryItemCoordinatorInput: AnyObject {
    
    func runAttachSubtitlesFlow(completion: @escaping (_ url: URL?) -> Void)
}

public protocol LibraryItemCoordinator: LibraryItemCoordinatorInput {
    
    func start(at: StackPresentationContainer)
}
