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
                
                guard Task.isCancelled else {
                    return
                }
                
                guard let libraryFlow = libraryFlow else {
                    continue
                }
                
                
                libraryFlow.runAddMediaLibratyItemFlow(targetFolderId: nil)
                
                for await addMediaLibraryItemFlow in libraryFlow.addMediaLibraryItemFlow.values {
                    
                    guard Task.isCancelled else {
                        return
                    }
                    
                    guard let addMediaLibraryItemFlow = addMediaLibraryItemFlow else {
                        continue
                    }
                    
                }
                
            }
        }
//        Task {
//
//            await self.waitForActiveLibraryFlow(applicationFlowModel: applicationFlowModel)
//
//        }
//
//        libraryFlowObserver = applicationFlowModel.mainFlowModel.libraryFlow
//            .sink { [weak self] libraryFlow in
//
//                guard let libraryFlow = libraryFlow else {
//
//                }
//                libraryFlow?.addMediaLibraryItemFlow.
//            }
//
//        applicationFlowModel.mainFlowModel.mainTabBarViewModel.selectLibraryTab()
//
//
//        applicationFlowModel.mainFlowModel.libraryFlow.value?.addMediaLibraryItemFlow
//        applicationFlowModel.mainFlowModel.libraryFlow.value?.runAddMediaLibratyItemFlow(targetFolderId: nil)
    }
}

//extension CurrentValueSubject where Output: Optional<Any> {
//    
//    func firstNotNil() async throws -> WrappedValue {
//
//        for try await item in values {
//
//            guard Task.isCancelled else {
//                throw NSError(domain: "", code: 0)
//            }
//
//            guard let item = item else {
//                continue
//            }
//
//            return item
//        }
//    }
//}
