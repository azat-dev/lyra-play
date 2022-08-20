//
//  AppCoordinator.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 12.06.22.
//

import Foundation
import UIKit
import CoreData
import UniformTypeIdentifiers

// MARK: - Interfaces

protocol AppCoordinator: AudioFilesBrowserCoordinator, LibraryItemCoordinator {
    
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
    
    private lazy var playingNowService: NowPlayingInfoService = {
        
        return DefaultNowPlayingInfoService()
    } ()
    
    private lazy var audioSession: DefaultAudioSession = {

        return DefaultAudioSession()
    } ()
    
    private lazy var audioPlayer: AudioPlayer = {

        return DefaultAudioPlayer(audioSession: audioSession)
    } ()
    
    private lazy var loadTrackUseCase: LoadTrackUseCase = {
        
        return DefaultLoadTrackUseCase(
            audioLibraryRepository: audioLibraryRepository,
            audioFilesRepository: audioFilesRepository
        )
    } ()
    
    private lazy var currentPlayerStateUseCase: CurrentPlayerStateUseCase = {
        
        let currentState = DefaultCurrentPlayerStateUseCase(
            audioPlayer: audioPlayer,
            showMediaInfoUseCase: showMediaInfoUseCase
        )
        
        currentState.info.observe(on: self) { [weak self] info in
            
            guard let info = info else {
                return
            }

            self?.playingNowService.update(from: info)
        }
        
        return currentState
    } ()
    
    private lazy var playMediaUseCase: PlayMediaUseCase = {
        
        return DefaultPlayMediaUseCase(
            audioPlayer: audioPlayer,
            loadTrackUseCase: loadTrackUseCase
        )
    } ()
    
    private lazy var playMediaUseCaseOutput: PlayMediaUseCaseOutput = {
        
        return playMediaUseCase
    } ()
    
    private lazy var playMediaUseCaseInput: PlayMediaUseCaseInput = {
        
        return playMediaUseCase
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
    
    private lazy var showMediaInfoUseCase: ShowMediaInfoUseCase = {
        
        return DefaultShowMediaInfoUseCase(
            audioLibraryRepository: audioLibraryRepository,
            imagesRepository: imagesRepository,
            defaultImage: UIImage(systemName: "lock")!.pngData()!
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
    
    private lazy var subtitlesFilesRepository: FilesRepository = {
        
        let url = try! FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        )
        
        let subtitlesDirectory = url.appendingPathComponent("subtitles", isDirectory: true)
        
        return try! LocalFilesRepository(baseDirectory: subtitlesDirectory)
    } ()
    
    private lazy var subtitlesRepository: SubtitlesRepository = {
      
        return CoreDataSubtitlesRepository(coreDataStore: coreDataStore)
    } ()
    
    private lazy var subtitlesParser: SubtitlesParser = {
        
        let textSplitter = DefaultTextSplitter()
        let lyricsParser = LyricsParser(textSplitter: textSplitter)
        
        let subRipParser = SubRipFileFormatParser(textSplitter: textSplitter)
        
        return DefaultSubtitlesParser(parsers: [
            ".srt": subRipParser,
            ".lrc": lyricsParser
        ])
    } ()
    
    private lazy var importSubtitlesUseCase = {
        
        return DefaultImportSubtitlesUseCase(
            subtitlesRepository: subtitlesRepository,
            subtitlesParser: subtitlesParser,
            subtitlesFilesRepository: subtitlesFilesRepository,
            supportedExtensions: [".srt", ".lrc"]
        )
    } ()
    
    private lazy var loadSubtitlesUseCase: LoadSubtitlesUseCase = {
        return DefaultLoadSubtitlesUseCase(
            subtitlesRepository: subtitlesRepository,
            subtitlesFiles: subtitlesFilesRepository,
            subtitlesParser: subtitlesParser
        )
    } ()
    
    
    private lazy var playSubtitlesUseCaseFactory: PlaySubtitlesUseCaseFactory = {
        
        return DefaultPlaySubtitlesUseCaseFactory(
            subtitlesIteratorFactory: DefaultSubtitlesIteratorFactory(),
            scheduler: DefaultScheduler(timer: DefaultActionTimer())
        )
    } ()
        
    private lazy var playMediaWithSubtitlesUseCase: PlayMediaWithSubtitlesUseCase = {
        
        return DefaultPlayMediaWithSubtitlesUseCase(
            playMediaUseCase: playMediaUseCase,
            playSubtitlesUseCaseFactory: playSubtitlesUseCaseFactory,
            loadSubtitlesUseCase: loadSubtitlesUseCase
        )
    } ()
    
    private lazy var dictionaryRepository: DictionaryRepository = {
        return CoreDataDictionaryRepository(coreDataStore: coreDataStore)
    } ()
    
    private lazy var provideTranslationsForSubtitlesUseCase: ProvideTranslationsForSubtitlesUseCase = {
        
        return DefaultProvideTranslationsForSubtitlesUseCase(
            dictionaryRepository: dictionaryRepository,
            textSplitter: DefaultTextSplitter(),
            lemmatizer: DefaultLemmatizer()
        )
    } ()
    
    private lazy var provideTranslationsToPlayUseCase: ProvideTranslationsToPlayUseCase = {
        
        return DefaultProvideTranslationsToPlayUseCase(
            provideTranslationsForSubtitlesUseCase: provideTranslationsForSubtitlesUseCase
        )
    } ()
    
    private lazy var pronounceTranslationsUseCase: PronounceTranslationsUseCase = {
        
        return DefaultPronounceTranslationsUseCase(
            textToSpeechConverter: DefaultTextToSpeechConverter(),
            audioPlayer: DefaultAudioPlayer(audioSession: audioSession)
        )
    } ()
    
    
    private lazy var playMediaWithTranslationsUseCase: PlayMediaWithTranslationsUseCase = {
        
        return DefaultPlayMediaWithTranslationsUseCase(
            playMediaWithSubtitlesUseCase: playMediaWithSubtitlesUseCase,
            playSubtitlesUseCaseFactory: playSubtitlesUseCaseFactory,
            provideTranslationsToPlayUseCase: provideTranslationsToPlayUseCase,
            pronounceTranslationsUseCase: pronounceTranslationsUseCase
        )
    } ()
    
    private lazy var browseDictionaryUseCase: BrowseDictionaryUseCase = {
      
        return DefaultBrowseDictionaryUseCase(dictionaryRepository: dictionaryRepository)
    } ()
    
    
    init(navigationController: UINavigationController) {
        
        self.navigationController = navigationController
    }
    
    func makeAudioFilesBrowserVC() -> AudioFilesBrowserViewController {
        
        let factory = AudioFilesBrowserViewControllerFactory(
            coordinator: self,
            browseFilesUseCase: browseFilesUseCase,
            importFileUseCase: importFileUseCase,
            playMediaUseCase: playMediaUseCase
        )
        return factory.build()
    }
    
    func makeDictionaryListBrowserVC() -> DictionaryListBrowserViewController {
        
        let factory = DictionaryListBrowserViewControllerFactory(
            coordinator: self,
            browseDictionaryUseCase: browseDictionaryUseCase
        )
        return factory.build()
    }
    
    private func openFilePicker(multiple: Bool, documentTypes: [String], completion: @escaping (_ urls: [URL]?) -> Void) {

        let vc = FilePickerViewController.create(
            allowMultipleSelection: true,
            documentTypes: documentTypes,
            onSelect: { urls in
                
                completion(urls)
            },
            onCancel: {
                
                completion(nil)
            }
        )
        
        self.navigationController.topViewController?.present(vc, animated: true)
    }
    
    func chooseFiles(completion: @escaping (_ urls: [URL]?) -> Void) {
        
        openFilePicker(
            multiple: true,
            documentTypes: ["public.audio"],
            completion: completion
        )
    }
    
    func start() {
        
        let tabBarVC = UITabBarController()
        
        let audioFilesBrowserNavigationController = UINavigationController()
        audioFilesBrowserNavigationController.pushViewController(makeAudioFilesBrowserVC(), animated: false)
        
        let dictionaryBrowserNavigationController = UINavigationController()
        dictionaryBrowserNavigationController.pushViewController(makeDictionaryListBrowserVC(), animated: false)
        
        tabBarVC.viewControllers = [
            audioFilesBrowserNavigationController,
            dictionaryBrowserNavigationController,
        ]
        
        tabBarVC.selectedViewController = tabBarVC.viewControllers?.first
        navigationController.pushViewController(tabBarVC, animated: false)
    }
}

// MARK: - LibraryItemCoordinator

extension DefaultAppCoordinator: LibraryItemCoordinator {
    
    func chooseSubtitles(completion: @escaping (_ url: URL?) -> Void) {
        
        openFilePicker(
            multiple: true,
            documentTypes: ["com.azatkaiumov.subtitles"],
            completion: { completion($0?.first) }
        )
    }
    
    func showImportSubtitlesError() {
    }
}

// MARK: - AudioFilesBrowserCoordinator

extension DefaultAppCoordinator: AudioFilesBrowserCoordinator {
    
    
    func openLibraryItem(trackId: UUID) {
        
        let factory = LibraryItemViewControllerFactory(
            coordnator: self,
            showMediaInfoUseCase: showMediaInfoUseCase,
            currentPlayerStateUseCase: currentPlayerStateUseCase,
            playMediaUseCase: playMediaWithTranslationsUseCase,
            importSubtitlesUseCase: importSubtitlesUseCase,
            loadSubtitlesUseCase: loadSubtitlesUseCase
        )
        
        let vc = factory.build(with: trackId)
        
        navigationController.pushViewController(vc, animated: true)
    }
    
    func openAudioPlayer(trackId: UUID) {
        
        let factory = PlayerViewControllerFactory(
            playMediaUseCase: playMediaUseCase
        )
        
        let vc = factory.build()
        
        let topViewController = self.navigationController.topViewController
        topViewController?.modalPresentationStyle = .pageSheet
        topViewController?.present(vc, animated: true)
    }
}


// MARK: - DictionaryListBrowserCoordinator

extension DefaultAppCoordinator: DictionaryListBrowserCoordinator {
    
    func addNewDictionaryItem(completion: @escaping (DictionaryItem) -> Void) {
        
        let alert = UIAlertController(title: "New dictionary item", message: "", preferredStyle: .alert)
        
        alert.addTextField()
        alert.addTextField()
        
        alert.addAction(.init(title: "Cancel", style: .cancel))
        
        let saveAction = UIAlertAction(title: "Submit", style: .default) { [weak self, weak alert] action in
            
            guard
                let self = self,
                let originalText = alert?.textFields?[0].text,
                let translatedText = alert?.textFields?[1].text
            else {
                return
            }
            
            let lemmatizer = DefaultLemmatizer()

            let newItem = DictionaryItem(
                id: nil,
                createdAt: nil,
                updatedAt: nil,
                originalText: originalText,
                lemma: lemmatizer.lemmatize(text: originalText).first?.lemma ?? originalText,
                language: "English",
                translations: [
                    .init(id: UUID(), text: translatedText)
                ]
            )
            
            Task {
                
                await self.dictionaryRepository.putItem(newItem)
                completion(newItem)
            }
            
        }
        
        alert.addAction(saveAction)
        
        let topViewController = self.navigationController.topViewController
        topViewController?.present(alert, animated: true)
    }
}
