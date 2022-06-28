//
//  AudioFilesBrowserViewModel.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 27.06.22.
//

import Foundation

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
    private let browseUseCase: BrowseAudioFilesUseCase
    private let importFileUseCase: ImportAudioFileUseCase
    
    public var isLoading: Observable<Bool>
    public weak var filesDelegate: AudioFilesBrowserUpdateDelegate?
    
    public init(
        coordinator: AudioFilesBrowserCoordinator,
        browseUseCase: BrowseAudioFilesUseCase,
        importFileUseCase: ImportAudioFileUseCase
    ) {
        
        self.coordinator = coordinator
        self.browseUseCase = browseUseCase
        self.importFileUseCase = importFileUseCase
        self.isLoading = Observable(true)
    }
    
    private func onOpen(_ cellId: UUID) {
        
    }
    
    public func load() async {
        
        isLoading.value = true
        
        let result = await browseUseCase.listFiles()
        
        guard case .success(let loadedFiles) = result else {
            return
        }
        
        let files = loadedFiles.map { file in
            return AudioFilesBrowserCellViewModel(
                id: file.id!,
                title: file.name,
                description: file.artist ?? "",
                onOpen: self.onOpen
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
