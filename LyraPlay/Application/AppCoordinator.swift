//
//  AppCoordinator.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 12.06.22.
//

import Foundation
import UIKit
import CoreData

// MARK: - Interfaces

protocol AppCoordinator: AudioFilesBrowserCoordinator {
    
    func start()
}

// MARK: - Implementations

final class DefaultAppCoordinator: AppCoordinator {
    
    private let navigationController: UINavigationController
    
    private lazy var coreDataStore: CoreDataStore = {
        let url = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("LyraPlay.sqlite")
        
        return try! CoreDataStore(storeURL: url)
    } ()
    
    private lazy var playerStateRepository: PlayerStateRepository = {
        
        return DefaultPlayerStateRepository(
            keyValueStore: UserDefaultsKeyValueStore(storeName: "playerState"),
            key: "currentState"
        )
    } ()
    
    private lazy var audioPlayerService: AudioPlayerService = {
        
        return DefaultAudioPlayerService()
    } ()
    
    private lazy var audioPlayerUseCase: AudioPlayerUseCase = {
        
        return DefaultAudioPlayerUseCase(
            audioLibraryRepository: audioLibraryRepository,
            audioFilesRepository: audioFilesRepository,
            imagesRepository: imagesRepository,
            playerStateRepository: playerStateRepository,
            audioPlayerService: audioPlayerService
        )
    } ()
    
    private lazy var audioLibraryRepository: AudioLibraryRepository = {
        
        return CoreDataAudioLibraryRepository(coreDataStore: coreDataStore)
    } ()
    
    private lazy var browseFilesUseCase: BrowseAudioLibraryUseCase = {
        
        return DefaultBrowseAudioLibraryUseCase(
            audioLibraryRepository: audioLibraryRepository,
            imagesRepository: imagesRepository
        )
    } ()
    
    private lazy var imagesRepository: FilesRepository = {
        
        let url = try! FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        )
        
        
        let imagesDirectory = url.appendingPathComponent("audiofiles_images", isDirectory: true)
        
        return try! LocalFilesRepository(baseDirectory: imagesDirectory)
    } ()
    
    
    private lazy var audioFilesRepository: FilesRepository = {
        
        let url = try! FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        )
        
        
        let imagesDirectory = url.appendingPathComponent("audiofiles_data", isDirectory: true)
        
        return try! LocalFilesRepository(baseDirectory: imagesDirectory)
    } ()
    
    
    private lazy var importFileUseCase: ImportAudioFileUseCase = {
        
        return DefaultImportAudioFileUseCase(
            audioLibraryRepository: audioLibraryRepository,
            audioFilesRepository: audioFilesRepository,
            imagesRepository: imagesRepository,
            tagsParser: DefaultTagsParser()
        )
    } ()
    
    init(navigationController: UINavigationController) {
        
        self.navigationController = navigationController
    }
    
    func makeAudioFilesBrowserVC() -> AudioFilesBrowserViewController {
        
        let factory = AudioFilesBrowserViewControllerFactory(
            coordinator: self,
            browseFilesUseCase: browseFilesUseCase,
            importFileUseCase: importFileUseCase,
            audioPlayerUseCase: audioPlayerUseCase
        )
        return factory.build()
    }
    
    func chooseFiles(completion: @escaping (_ urls: [URL]?) -> Void) {
        
        let vc = FilePickerViewController.create(
            allowMultipleSelection: true,
            documentTypes: [
                "public.audio"
            ],
            onSelect: { urls in
                
                completion(urls)
            },
            onCancel: {
                
                completion(nil)
                
            }
        )
        self.navigationController.topViewController?.present(vc, animated: true)
    }
    
    func start() {
        
        let vc = makeAudioFilesBrowserVC()
        navigationController.pushViewController(vc, animated: false)
    }
}
