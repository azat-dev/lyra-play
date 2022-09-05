//
//  LibraryItemCoordinator.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 05.09.2022.
//

import Foundation

public protocol LibraryItemCoordinatorInput: AnyObject {
    
    func runAttachSubtitlesFlow(completion: @escaping (_ url: URL?) -> Void)
}

public protocol LibraryItemCoordinator: Coordinator, LibraryItemCoordinatorInput {
    
    func start(at: StackPresentationContainer, mediaId: UUID)
}
