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
    public var isLoading: Observable<Bool>
    public weak var filesDelegate: AudioFilesBrowserUpdateDelegate?
    
    public init(browseUseCase: BrowseAudioFilesUseCase, coordinator: AudioFilesBrowserCoordinator) {
        
        self.browseUseCase = browseUseCase
        self.coordinator = coordinator
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
    
    public func addNewItem() {
        
        coordinator.chooseFiles { urls in
            
            guard let urls = urls else {
                return
            }

            print(urls)
        }
    }
}
