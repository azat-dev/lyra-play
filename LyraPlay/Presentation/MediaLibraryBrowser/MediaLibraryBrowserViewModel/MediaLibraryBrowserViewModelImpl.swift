//
//  MediaLibraryBrowserViewModelImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 01.09.2022.
//

import Foundation
import UIKit

public final class MediaLibraryBrowserViewModelImpl: MediaLibraryBrowserViewModel {

    // MARK: - Properties

    private weak var delegate: MediaLibraryBrowserViewModelDelegate?
    private let browseUseCase: BrowseMediaLibraryUseCase
    private let importFileUseCase: ImportAudioFileUseCase
    
    public var isLoading = Observable<Bool>(true)
    public var filesDelegate: MediaLibraryBrowserUpdateDelegate?
    
    private var stubItemImage = UIImage(named: "Image.CoverPlaceholder")!

    // MARK: - Initializers

    public init(
        delegate: MediaLibraryBrowserViewModelDelegate,
        browseUseCase: BrowseMediaLibraryUseCase,
        importFileUseCase: ImportAudioFileUseCase
    ) {

        self.delegate = delegate
        self.browseUseCase = browseUseCase
        self.importFileUseCase = importFileUseCase
        
        self.isLoading = Observable(true)
    }
}

// MARK: - Input Methods

extension MediaLibraryBrowserViewModelImpl {

    private func onOpen(_ cellId: UUID) {
        
    }
    
    private func onPlay(_ trackId: UUID) {
        
        delegate?.runOpenLibraryItemFlow(mediaId: trackId)
    }
    
    private func loadImages(names: [String]) async -> [String: UIImage] {
        
        var images = [String: UIImage]()
        
        for imageName in names {
            
            let result = await browseUseCase.fetchImage(name: imageName)
            guard case .success(let imageData) = result else {
                continue
            }
            
            images[imageName] = UIImage(data: imageData)
        }
        
        return images
    }

    public func load() async -> Void {

        isLoading.value = true
        
        let result = await browseUseCase.listFiles()
        
        guard case .success(let loadedFiles) = result else {
            return
        }
        
        let images = await loadImages(names: loadedFiles.compactMap { $0.coverImage })
        
        let files = loadedFiles.map { file in
            
            return MediaLibraryBrowserCellViewModel(
                id: file.id!,
                title: file.name,
                description: file.artist ?? "Unknown",
                image: images[file.coverImage ?? ""] ?? stubItemImage,
                onOpen: self.onOpen,
                onPlay: self.onPlay
            )
        }
        
        filesDelegate?.filesDidUpdate(updatedFiles: files)
        self.isLoading.value = false
    }
    
    public func addNewItem() -> Void {
        
        delegate?.runImportMediaFilesFlow()
    }
}

// MARK: - Output Methods

extension MediaLibraryBrowserViewModelImpl {

}
