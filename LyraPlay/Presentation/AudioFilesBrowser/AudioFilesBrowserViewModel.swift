//
//  AudioFilesBrowserViewModel.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 27.06.22.
//

import Foundation
import UIKit

// MARK: - Interfaces

public protocol AudioFilesBrowserCoordinator: AnyObject {
    
    func chooseFiles(completion: @escaping (_ urls: [URL]?) -> Void) 
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

public final class DefaultAudioFilesBrowserViewModel: AudioFilesBrowserViewModel {

    private let coordinator: AudioFilesBrowserCoordinator
    private let browseUseCase: BrowseAudioLibraryUseCase
    private let importFileUseCase: ImportAudioFileUseCase
    private let audioPlayerUseCase: AudioPlayerUseCase
    
    public var isLoading: Observable<Bool>
    public weak var filesDelegate: AudioFilesBrowserUpdateDelegate?
    private var stubItemImage = UIImage(systemName: "music.note")!
    
    public init(
        coordinator: AudioFilesBrowserCoordinator,
        browseUseCase: BrowseAudioLibraryUseCase,
        importFileUseCase: ImportAudioFileUseCase,
        audioPlayerUseCase: AudioPlayerUseCase
    ) {
        
        self.coordinator = coordinator
        self.browseUseCase = browseUseCase
        self.importFileUseCase = importFileUseCase
        self.audioPlayerUseCase = audioPlayerUseCase
        self.isLoading = Observable(true)
    }
    
    private func onOpen(_ cellId: UUID) {
        
    }
    
    private func onPlay(_ trackId: UUID) {
        
        Task {
            await audioPlayerUseCase.setTrack(fileId: trackId)
            await audioPlayerUseCase.play()
        }
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
                description: file.artist ?? "",
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
        
        coordinator.chooseFiles { [weak self] urls in
            
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
