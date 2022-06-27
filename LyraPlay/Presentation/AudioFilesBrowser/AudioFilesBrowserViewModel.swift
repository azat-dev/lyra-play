//
//  AudioFilesBrowserViewModel.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 27.06.22.
//

import Foundation

// MARK: - Interfaces

public struct FileBrowserItem {
    
    public var id: UUID
    public var title: String
    public var description: String
}

public protocol AudioFilesBrowserViewModelOutput {
    
    var isLoading: Observable<Bool> { get }
    var files: Observable<[FileBrowserItem]> { get }
}

public protocol AudioFilesBrowserViewModelInput {
    
    func load() async
}

public protocol AudioFilesBrowserViewModel: AudioFilesBrowserViewModelInput, AudioFilesBrowserViewModelOutput {
}

// MARK: - Implementations

public final class DefaultAudioFilesBrowserViewModel: AudioFilesBrowserViewModel {

    private let browseUseCase: BrowseAudioFilesUseCase
    public var files: Observable<[FileBrowserItem]>
    public var isLoading: Observable<Bool>
    
    public init(browseUseCase: BrowseAudioFilesUseCase) {
        
        self.browseUseCase = browseUseCase
        self.isLoading = Observable(true)
        self.files = Observable([])
    }
    
    public func load() async {
        
        isLoading.value = true
        
        let result = await browseUseCase.listFiles()
        
        guard case .success(let loadedFiles) = result else {
            return
        }
        
        self.files.value = loadedFiles.map { loadedFile in
            return FileBrowserItem(
                id: loadedFile.id!,
                title: loadedFile.name,
                description: loadedFile.artist ?? ""
            )
        }
        
        self.isLoading.value = false
    }
}
