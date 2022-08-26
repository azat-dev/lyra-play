//
//  AudioFilesBrowserViewModel.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 27.06.22.
//

import Foundation
import UIKit

// MARK: - Interfaces

public protocol LibraryCoordinator: AnyObject {
    
    func runImportMediaFilesFlow(completion: @escaping (_ urls: [URL]?) -> Void)
    
    func runOpenLibraryItemFlow(mediaId: UUID)
}

public protocol AudioFilesBrowserUpdateDelegate: AnyObject {
    
    func filesDidUpdate(updatedFiles: [AudioFilesBrowserCellViewModel])
}

public protocol AudioFilesBrowserViewModelOutput {
    
    var isLoading: Observable<Bool> { get }
    var filesDelegate: AudioFilesBrowserUpdateDelegate? { get set }
}

public protocol AudioFilesBrowserViewModelInput {
    
    func load() async
    func addNewItem()
}

public protocol AudioFilesBrowserViewModel: AnyObject, AudioFilesBrowserViewModelInput, AudioFilesBrowserViewModelOutput {
}

// MARK: - Implementations

public final class AudioFilesBrowserViewModelImpl: AudioFilesBrowserViewModel {

    private let coordinator: LibraryCoordinator
    private let browseUseCase: BrowseAudioLibraryUseCase
    private let importFileUseCase: ImportAudioFileUseCase
    
    public var isLoading: Observable<Bool>
    public weak var filesDelegate: AudioFilesBrowserUpdateDelegate?
    private var stubItemImage = UIImage(named: "Image.CoverPlaceholder")!
    
    public init(
        coordinator: LibraryCoordinator,
        browseUseCase: BrowseAudioLibraryUseCase,
        importFileUseCase: ImportAudioFileUseCase
    ) {
        
        self.coordinator = coordinator
        self.browseUseCase = browseUseCase
        self.importFileUseCase = importFileUseCase
        
        self.isLoading = Observable(true)
    }
    
    private func onOpen(_ cellId: UUID) {
        
    }
    
    private func onPlay(_ trackId: UUID) {
        
        coordinator.runOpenLibraryItemFlow(mediaId: trackId)
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
    
    public func load() async {
        
        isLoading.value = true
        
        let result = await browseUseCase.listFiles()
        
        guard case .success(let loadedFiles) = result else {
            return
        }
        
        let images = await loadImages(names: loadedFiles.compactMap { $0.coverImage })
        
        let files = loadedFiles.map { file in
            
            return AudioFilesBrowserCellViewModel(
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
    
    private func importFiles(urls: [URL]) async {
        
        for url in urls {
            
            url.startAccessingSecurityScopedResource()
            
            guard let data = try? Data(contentsOf: url) else {
                continue
            }
            
            let result = await importFileUseCase.importFile(
                originalFileName: url.lastPathComponent,
                fileData: data
            )
        }
        
        await load()
    }
    
    public func addNewItem() {
        
        coordinator.runImportMediaFilesFlow { [weak self] urls in
            
            guard let urls = urls, let self = self else {
                return
            }
            
            let importFiles = self.importFiles

            Task {
                await importFiles(urls)
            }
        }
    }
}
