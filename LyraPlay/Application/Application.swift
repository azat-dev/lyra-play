//
//  Application.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 05.09.22.
//

import Foundation
import CoreData

public class Application {

    // MARK: - Properties
    
    private var mainCoordinator: MainCoordinator?
    
    private lazy var coreDataStore: CoreDataStore = {
        
        let url = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("LyraPlay.sqlite")
        return try! CoreDataStore(storeURL: url)
    } ()
    
    private lazy var audioSession: AudioSessionImpl = {

        return AudioSessionImpl()
    } ()
    
    
    private lazy var audioLibraryRepository: AudioLibraryRepository = {
        
        return CoreDataAudioLibraryRepository(coreDataStore: coreDataStore)
    } ()
    
    private lazy var dictionaryRepository: DictionaryRepository = {
        
        return CoreDataDictionaryRepository(coreDataStore: coreDataStore)
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
    

    // MARK: - Initializers
    
    public init() {}
    
    
    // MARK: - Methods
    
    public func start(container: StackPresentationContainer) {
        
        let mainTabBarViewModelFactory = MainTabBarViewModelImplFactory()
        let mainTabBarViewFactory = MainTabBarViewControllerFactory()
        
        let libraryViewModelFactory = AudioFilesBrowserViewModelImplFactory()
        let libraryViewFactory = AudioFilesBrowserViewControllerFactory()

        let browseAudioLibraryUseCaseFactory = BrowseAudioLibraryUseCaseImplFactory(
            audioLibraryRepository: audioLibraryRepository,
            imagesRepository: imagesRepository
        )
        
        let tagsParser = TagsParserImpl()
        
        let imporAudioFileUseCaseFactory = ImportAudioFileUseCaseImplFactory(
            audioLibraryRepository: audioLibraryRepository,
            audioFilesRepository: audioFilesRepository,
            imagesRepository: imagesRepository,
            tagsParser: tagsParser
        )
        
        let libraryCoordinatorFactory = LibraryCoordinatorFactoryImpl(
            viewModelFactory: libraryViewModelFactory,
            viewFactory: libraryViewFactory,
            browseAudioLibraryUseCaseFactory: browseAudioLibraryUseCaseFactory,
            importAudioFileUseCaseFactory: imporAudioFileUseCaseFactory
        )
        
        let browseDictionaryUseCase = BrowseDictionaryUseCaseImpl(
            dictionaryRepository: dictionaryRepository
        )
        
        let dictionaryViewModelFactory = DictionaryListBrowserViewModelImplFactory(
            browseDictionaryUseCase: browseDictionaryUseCase
        )
        
        let dictionaryViewFactory = DictionaryListBrowserViewControllerFactory()
        
        let dictionaryCoordinatorFactory = DictionaryCoordinatorFactoryImpl(
            viewModelFactory: dictionaryViewModelFactory,
            viewFactory: dictionaryViewFactory
        )
        
        let mainTabBarCoordinatorFactory = MainTabBarCoordinatorImplFactory(
            mainTabBarViewModelFactory: mainTabBarViewModelFactory,
            mainTabBarViewFactory: mainTabBarViewFactory,
            libraryCoordinatorFactory: libraryCoordinatorFactory,
            dictionaryCoordinatorFactory: dictionaryCoordinatorFactory
        )
        
        let mainCoordinator = MainCoordinatorImpl(
            mainTabBarCoordinatorFactory: mainTabBarCoordinatorFactory
        )
        
        self.mainCoordinator = mainCoordinator
        mainCoordinator.start(at: container)
    }
}
