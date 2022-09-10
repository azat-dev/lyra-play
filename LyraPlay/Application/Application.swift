//
//  Application.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 05.09.22.
//

import Foundation
import CoreData
import UIKit

public class Application {
    
    private lazy var appPresenter: MainFlowPresenter = {
        
        let appFlow = makeFlow()
        return makePresenter(flow: appFlow)
    } ()

    // MARK: - Properties
    
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
    
    
    private lazy var audioPlayer: AudioPlayer = {

        return AudioPlayerImpl(audioSession: audioSession)
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

            // FIXME:
//            self?.playingNowService.update(from: info)
        }
        
        return currentState
    } ()
    
    private lazy var showMediaInfoUseCase: ShowMediaInfoUseCase = {
        
        return ShowMediaInfoUseCaseImpl(
            audioLibraryRepository: audioLibraryRepository,
            imagesRepository: imagesRepository,
            defaultImage: UIImage(named: "Image.CoverPlaceholder")!.pngData()!
        )
    } ()

    private lazy var subtitlesRepository: SubtitlesRepository = {
      
        return CoreDataSubtitlesRepository(coreDataStore: coreDataStore)
    } ()
    
    private lazy var loadSubtitlesUseCase: LoadSubtitlesUseCase = {
        return LoadSubtitlesUseCaseImpl(
            subtitlesRepository: subtitlesRepository,
            subtitlesFiles: subtitlesFilesRepository,
            subtitlesParser: subtitlesParser
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
    
    private lazy var loadTrackUseCase: LoadTrackUseCase = {
        
        return LoadTrackUseCaseImpl(
            audioLibraryRepository: audioLibraryRepository,
            audioFilesRepository: audioFilesRepository
        )
    } ()

    private lazy var playMediaUseCase: PlayMediaUseCase = {
        
        return PlayMediaUseCaseImpl(
            audioPlayer: audioPlayer,
            loadTrackUseCase: loadTrackUseCase
        )
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
    
    private lazy var importSubtitlesUseCase: ImportSubtitlesUseCase = {

        let factory = ImportSubtitlesUseCaseImplFactory(
            supportedExtensions: [".srt", ".lrc"],
            subtitlesRepository: subtitlesRepository,
            subtitlesParser: subtitlesParser,
            subtitlesFilesRepository: subtitlesFilesRepository
        )
        
        return factory.create()
    } ()
    
    private lazy var playSubtitlesUseCaseFactory: PlaySubtitlesUseCaseFactory = {

        return PlaySubtitlesUseCaseImplFactory(
            subtitlesIteratorFactory: SubtitlesIteratorFactoryImpl(),
            schedulerFactory: SchedulerImplFactory(actionTimerFactory: ActionTimerFactoryImpl())
        )
    } ()
        
    private lazy var playMediaWithSubtitlesUseCase: PlayMediaWithSubtitlesUseCase = {
        
        return PlayMediaWithSubtitlesUseCaseImpl(
            playMediaUseCase: playMediaUseCase,
            playSubtitlesUseCaseFactory: playSubtitlesUseCaseFactory,
            loadSubtitlesUseCase: loadSubtitlesUseCase
        )
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

    // MARK: - Initializers
    
    public init() {
        
    }
    
    // MARK: - Methods
    
    public func start(container: UIWindow) {
        
        appPresenter.present(at: container)
    }
    
    func makeFlow() -> MainFlowModel {
        
        let mainTabBarViewModelFactory = MainTabBarViewModelImplFactory()

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
        
        let importSubtitlesUseCaseFactory = ImportSubtitlesUseCaseImplFactory(
            supportedExtensions: [".srt", ".lrc"],
            subtitlesRepository: subtitlesRepository,
            subtitlesParser: subtitlesParser,
            subtitlesFilesRepository: subtitlesFilesRepository
        )

        let libraryViewModelFactory = AudioFilesBrowserViewModelImplFactory(
            browseAudioLibraryUseCaseFactory: browseAudioLibraryUseCaseFactory,
            importAudioFileUseCaseFactory: imporAudioFileUseCaseFactory
        )
        
        let libraryItemViewModelFactory = LibraryItemViewModelImplFactory(
            showMediaInfoUseCase: showMediaInfoUseCase,
            currentPlayerStateUseCase: currentPlayerStateUseCase,
            playMediaUseCase: playMediaWithTranslationsUseCase,
            importSubtitlesUseCase: importSubtitlesUseCase,
            loadSubtitlesUseCase: loadSubtitlesUseCase
        )
        
        let browseDictionaryUseCase = BrowseDictionaryUseCaseImpl(
            dictionaryRepository: dictionaryRepository
        )
        
        let dictionaryViewModelFactory = DictionaryListBrowserViewModelImplFactory(
            browseDictionaryUseCase: browseDictionaryUseCase
        )
        
        let attachingSubtitlesProgressViewModelFactory = AttachingSubtitlesProgressViewModelImplFactory()
        
        let filesPickerViewModelFactory = FilesPickerViewModelImplFactory()
        
        let attachSubtitlesFlowModelFactory = AttachSubtitlesFlowModelImplFactory(
            allowedDocumentTypes: ["com.azatkaiumov.subtitles"],
            subtitlesPickerViewModelFactory: filesPickerViewModelFactory,
            attachingSubtitlesProgressViewModelFactory: attachingSubtitlesProgressViewModelFactory,
            importSubtitlesUseCaseFactory: importSubtitlesUseCaseFactory
        )
        
        let libraryItemFlowModelFactory = LibraryItemFlowModelImplFactory(
            libraryItemViewModelFactory: libraryItemViewModelFactory,
            attachSubtitlesFlowModelFactory: attachSubtitlesFlowModelFactory
        )
        
        let importMediaFilesFlowModelFactory = ImportMediaFilesFlowModelImplFactory(
            allowedDocumentTypes: ["public.audio"],
            filesPickerViewModelFactory: filesPickerViewModelFactory,
            importAudioFileUseCaseFactory: imporAudioFileUseCaseFactory
        )
        
        let libraryFlowModelFactory = LibraryFlowModelImplFactory(
            viewModelFactory: libraryViewModelFactory,
            libraryItemFlowModelFactory: libraryItemFlowModelFactory,
            importMediaFilesFlowModelFactory: importMediaFilesFlowModelFactory
        )
        let dictionaryFlowModelFactory = DictionaryFlowModelImplFactory(viewModelFactory: dictionaryViewModelFactory)
        
        return MainFlowModelImpl(
            mainTabBarViewModelFactory: mainTabBarViewModelFactory,
            libraryFlowModelFactory: libraryFlowModelFactory,
            dictionaryFlowModelFactory: dictionaryFlowModelFactory
        )
    }
    
    func makePresenter(flow: MainFlowModel) -> MainFlowPresenter {
        
        let filesPickerViewFactory = FilesPickerViewControllerFactory()
        
        let attachSubtitlesFlowPresenterFactory = AttachSubtitlesFlowPresenterImplFactory(
            subtitlesPickerViewFactory: filesPickerViewFactory,
            attachingSubtitlesProgressViewFactory: AttachingSubtitlesProgressViewControllerFactory()
        )
        
        let libraryItemFlowPresenterFactory = LibraryItemFlowPresenterImplFactory(
            libraryItemViewFactory: LibraryItemViewControllerFactory(),
            attachSubtitlesFlowPresenterFactory: attachSubtitlesFlowPresenterFactory
        )
        
        let importMediaFilesFlowPresenterFactory = ImportMediaFilesFlowPresenterImplFactory(filesPickerViewFactory: filesPickerViewFactory)
        
        let libraryFlowPresenterFactory = LibraryFlowPresenterImplFactory(
            listViewFactory: AudioFilesBrowserViewControllerFactory(),
            libraryItemFlowPresenterFactory: libraryItemFlowPresenterFactory,
            importMediaFilesFlowPresenterFactory: importMediaFilesFlowPresenterFactory
        )
        
        let dictionaryFlowPresenterFactory = DictionaryFlowPresenterImplFactory(
            listViewFactory: DictionaryListBrowserViewControllerFactory()
        )
        
        return MainFlowPresenterImpl(
            mainFlowModel: flow,
            mainTabBarViewFactory: MainTabBarViewControllerFactory(),
            libraryFlowPresenterFactory: libraryFlowPresenterFactory,
            dictionaryFlowPresenterFactory: dictionaryFlowPresenterFactory
        )
    }
}
