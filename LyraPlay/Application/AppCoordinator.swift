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

protocol AppCoordinator: LibraryCoordinator, LibraryItemCoordinator {
    
    func start()
}

// MARK: - Implementations

final class AppCoordinatorImpl: AppCoordinator, LibraryItemCoordinatorInput {
    
    private let navigationController: UINavigationController
    
    private lazy var coreDataStore: CoreDataStore = {
        
        let url = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("LyraPlay.sqlite")
        return try! CoreDataStore(storeURL: url)
    } ()
    
    private lazy var playerStateRepository: PlayerStateRepository = {
        
        return PlayerStateRepositoryImpl(
            keyValueStore: UserDefaultsKeyValueStore(storeName: "playerState"),
            key: "currentState"
        )
    } ()
    
    private lazy var playingNowService: NowPlayingInfoService = {
        
        return NowPlayingInfoServiceImpl()
    } ()
    
    private lazy var audioSession: AudioSessionImpl = {

        return AudioSessionImpl()
    } ()
    
    private lazy var audioPlayer: AudioPlayer = {

        return AudioPlayerImpl(audioSession: audioSession)
    } ()
    
    private lazy var loadTrackUseCase: LoadTrackUseCase = {
        
        return LoadTrackUseCaseImpl(
            audioLibraryRepository: audioLibraryRepository,
            audioFilesRepository: audioFilesRepository
        )
    } ()
    
    private lazy var currentPlayerStateUseCase: CurrentPlayerStateUseCase = {
        
        let currentState = CurrentPlayerStateUseCaseImpl(
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
        
        return PlayMediaUseCaseImpl(
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
        
        return BrowseAudioLibraryUseCaseImpl(
            audioLibraryRepository: audioLibraryRepository,
            imagesRepository: imagesRepository
        )
    } ()
    
    private lazy var showMediaInfoUseCase: ShowMediaInfoUseCase = {
        
        return ShowMediaInfoUseCaseImpl(
            audioLibraryRepository: audioLibraryRepository,
            imagesRepository: imagesRepository,
            defaultImage: UIImage(named: "Image.CoverPlaceholder")!.pngData()!
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
        
        return ImportAudioFileUseCaseImpl(
            audioLibraryRepository: audioLibraryRepository,
            audioFilesRepository: audioFilesRepository,
            imagesRepository: imagesRepository,
            tagsParser: TagsParserImpl()
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
        
        let textSplitter = TextSplitterImpl()
        let lyricsParser = LyricsParser(textSplitter: textSplitter)
        
        let subRipParser = SubRipFileFormatParser(textSplitter: textSplitter)
        
        return SubtitlesParserImpl(parsers: [
            ".srt": subRipParser,
            ".lrc": lyricsParser
        ])
    } ()
    
    private lazy var importSubtitlesUseCase = {
        
        return ImportSubtitlesUseCaseImpl(
            subtitlesRepository: subtitlesRepository,
            subtitlesParser: subtitlesParser,
            subtitlesFilesRepository: subtitlesFilesRepository,
            supportedExtensions: [".srt", ".lrc"]
        )
    } ()
    
    private lazy var loadSubtitlesUseCase: LoadSubtitlesUseCase = {
        return LoadSubtitlesUseCaseImpl(
            subtitlesRepository: subtitlesRepository,
            subtitlesFiles: subtitlesFilesRepository,
            subtitlesParser: subtitlesParser
        )
    } ()
    
    
    private lazy var playSubtitlesUseCaseFactory: PlaySubtitlesUseCaseFactory = {
        
        return PlaySubtitlesUseCaseFactoryImpl(
            subtitlesIteratorFactory: SubtitlesIteratorFactoryImpl(),
            scheduler: SchedulerImpl(timer: ActionTimerImpl())
        )
    } ()
        
    private lazy var playMediaWithSubtitlesUseCase: PlayMediaWithSubtitlesUseCase = {
        
        return PlayMediaWithSubtitlesUseCaseImpl(
            playMediaUseCase: playMediaUseCase,
            playSubtitlesUseCaseFactory: playSubtitlesUseCaseFactory,
            loadSubtitlesUseCase: loadSubtitlesUseCase
        )
    } ()
    
    private lazy var dictionaryRepository: DictionaryRepository = {
        return CoreDataDictionaryRepository(coreDataStore: coreDataStore)
    } ()
    
    private lazy var provideTranslationsForSubtitlesUseCase: ProvideTranslationsForSubtitlesUseCase = {
        
        return ProvideTranslationsForSubtitlesUseCaseImpl(
            dictionaryRepository: dictionaryRepository,
            textSplitter: TextSplitterImpl(),
            lemmatizer: LemmatizerImpl()
        )
    } ()
    
    private lazy var provideTranslationsToPlayUseCase: ProvideTranslationsToPlayUseCase = {
        
        return ProvideTranslationsToPlayUseCaseImpl(
            provideTranslationsForSubtitlesUseCase: provideTranslationsForSubtitlesUseCase
        )
    } ()
    
    private lazy var pronounceTranslationsUseCase: PronounceTranslationsUseCase = {
        
        return PronounceTranslationsUseCaseImpl(
            textToSpeechConverter: TextToSpeechConverterImpl(),
            audioPlayer: AudioPlayerImpl(audioSession: audioSession)
        )
    } ()
    
    
    private lazy var playMediaWithTranslationsUseCase: PlayMediaWithTranslationsUseCase = {
        
        return PlayMediaWithTranslationsUseCaseImpl(
            playMediaWithSubtitlesUseCase: playMediaWithSubtitlesUseCase,
            playSubtitlesUseCaseFactory: playSubtitlesUseCaseFactory,
            provideTranslationsToPlayUseCase: provideTranslationsToPlayUseCase,
            pronounceTranslationsUseCase: pronounceTranslationsUseCase
        )
    } ()
    
    private lazy var browseDictionaryUseCase: BrowseDictionaryUseCase = {
      
        return BrowseDictionaryUseCaseImpl(dictionaryRepository: dictionaryRepository)
    } ()
    
    
    init(navigationController: UINavigationController) {
        
        self.navigationController = navigationController
    }
    
    func makeAudioFilesBrowserVC() -> AudioFilesBrowserViewController {
        
        let factory = AudioFilesBrowserViewControllerFactoryDeprecated(
            coordinator: self,
            browseFilesUseCase: browseFilesUseCase,
            importFileUseCase: importFileUseCase
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
    
    func runImportMediaFilesFlow(completion: @escaping (_ urls: [URL]?) -> Void) {
        
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
        navigationController.isNavigationBarHidden = true
        navigationController.pushViewController(tabBarVC, animated: false)
    }
}

// MARK: - LibraryItemCoordinator

extension AppCoordinatorImpl: LibraryItemCoordinator {
    
    func runAttachSubtitlesFlow(completion: @escaping (_ url: URL?) -> Void) {
        
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

extension AppCoordinatorImpl: LibraryCoordinator {
    func start(at: StackPresentationContainer) {
        
    }
    
    
    
    func runOpenLibraryItemFlow(mediaId: UUID) {
        
        let factory = LibraryItemViewControllerFactory(
            coordnator: self,
            showMediaInfoUseCase: showMediaInfoUseCase,
            currentPlayerStateUseCase: currentPlayerStateUseCase,
            playMediaUseCase: playMediaWithTranslationsUseCase,
            importSubtitlesUseCase: importSubtitlesUseCase,
            loadSubtitlesUseCase: loadSubtitlesUseCase
        )
        
        let vc = factory.build(with: mediaId)
        
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

extension AppCoordinatorImpl: DictionaryListBrowserCoordinator {
    
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
            
            let lemmatizer = LemmatizerImpl()

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
