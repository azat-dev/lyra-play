//
//  MediaFileRouteHandler.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 09.03.23.
//

import Foundation
import Combine

public final class MediaFileRouteHandler: DeepLinkRouteHandler {
    
    private var currentTask: Task<Void, Never>?
    
    // MARK: - Initializers
    
    public init() {}
    
    // MARK: - Methods
    
    public func handle(
        deepLink: DeepLink,
        applicationFlowModel: ApplicationFlowModel
    ) {
        
        currentTask?.cancel()
        
        currentTask = Task {
            
            applicationFlowModel.mainFlowModel.mainTabBarViewModel.selectLibraryTab()
            
            for await libraryFlow in applicationFlowModel.mainFlowModel.libraryFlow.values {
                
                guard !Task.isCancelled else {
                    return
                }
                
                guard let libraryFlow = libraryFlow else {
                    continue
                }
                
                
                libraryFlow.runAddMediaLibratyItemFlow(targetFolderId: nil, fileUrl: deepLink)
            }
        }
    }
}
