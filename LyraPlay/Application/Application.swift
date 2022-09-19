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
    
    
    private lazy var mediaLibraryRepository: MediaLibraryRepository = {
        
        return CoreDataMediaLibraryRepository(coreDataStore: coreDataStore)
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
        
        
        let imagesDirectory = url.appendingPathComponent("mediafiles_images", isDirectory: true)
        
        return try! LocalFilesRepository(baseDirectory: imagesDirectory)
    } ()
    
    private lazy var audioFilesRepository: FilesRepository = {
        
        let url = try! FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        )
        
        
        let mediaFilesDirectory = url.appendingPathComponent("mediafiles_data", isDirectory: true)
        
        return try! LocalFilesRepository(baseDirectory: mediaFilesDirectory)
    } ()
    
    
    private lazy var audioPlayer: AudioPlayer = {

        return AudioPlayerImpl(audioSession: audioSession)
    } ()

    private lazy var showMediaInfoUseCase: ShowMediaInfoUseCase = {
        
        return ShowMediaInfoUseCaseImpl(
            mediaLibraryRepository: mediaLibraryRepository,
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
            mediaLibraryRepository: mediaLibraryRepository,
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
        
        let currentPlayerStateViewModelFactory = CurrentPlayerStateViewModelImplFactory(
            playMediaUseCase: playMediaWithTranslationsUseCase,
            showMediaInfoUseCase: showMediaInfoUseCase
        )
        
        let mainTabBarViewModelFactory = MainTabBarViewModelImplFactory(
            currentPlayerStateViewModelFactory: currentPlayerStateViewModelFactory
        )

        let browseMediaLibraryUseCaseFactory = BrowseMediaLibraryUseCaseImplFactory(
            mediaLibraryRepository: mediaLibraryRepository,
            imagesRepository: imagesRepository
        )
        
        let tagsParser = TagsParserImpl()
        
        let imporAudioFileUseCaseFactory = ImportAudioFileUseCaseImplFactory(
            mediaLibraryRepository: mediaLibraryRepository,
            audioFilesRepository: audioFilesRepository,
            imagesRepository: imagesRepository,
            tagsParser: tagsParser,
            fileNameGenerator: ImportAudioFileUseCaseFileNameGeneratorImpl()
        )
        
        let importSubtitlesUseCaseFactory = ImportSubtitlesUseCaseImplFactory(
            supportedExtensions: [".srt", ".lrc"],
            subtitlesRepository: subtitlesRepository,
            subtitlesParser: subtitlesParser,
            subtitlesFilesRepository: subtitlesFilesRepository
        )

        let libraryViewModelFactory = MediaLibraryBrowserViewModelImplFactory(
            browseMediaLibraryUseCaseFactory: browseMediaLibraryUseCaseFactory,
            importAudioFileUseCaseFactory: imporAudioFileUseCaseFactory
        )
        
        let libraryItemViewModelFactory = LibraryItemViewModelImplFactory(
            showMediaInfoUseCase: showMediaInfoUseCase,
            playMediaUseCase: playMediaWithTranslationsUseCase
        )
        
        let browseDictionaryUseCase = BrowseDictionaryUseCaseImpl(
            dictionaryRepository: dictionaryRepository
        )
        
        let audioPlayerFactory = AudioPlayerImplFactory(audioSession: audioSession)
        let textToSpeechConverterFactory = TextToSpeechConverterImplFactory()
        
        let pronounceTextUseCaseFactory = PronounceTextUseCaseImplFactory(
            textToSpeechConverterFactory: textToSpeechConverterFactory,
            audioPlayerFactory: audioPlayerFactory
        )
        
        let dictionaryViewModelFactory = DictionaryListBrowserViewModelImplFactory(
            browseDictionaryUseCase: browseDictionaryUseCase,
            pronounceTextUseCaseFactory: pronounceTextUseCaseFactory,
            dictionaryListBrowserItemViewModelFactory: DictionaryListBrowserItemViewModelImplFactory()
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
        
        let manageSubtitlesUseCase = ManageSubtitlesUseCaseImpl(
            subtitlesRepository: subtitlesRepository,
            subtitlesFilesRepository: subtitlesFilesRepository
        )
        
        let editMediaLibraryListUseCaseFactory = EditMediaLibraryListUseCaseImplFactory(
            mediaLibraryRepository: mediaLibraryRepository,
            mediaFilesRepository: audioFilesRepository,
            manageSubtitlesUseCase: manageSubtitlesUseCase,
            imagesRepository: imagesRepository
        )
        
        let confirmDialogViewModelFactory = ConfirmDialogViewModelImplFactory()
        
        let deleteMediaLibraryItemFlowModelFactory = DeleteMediaLibraryItemFlowModelImplFactory(
            editMediaLibraryListUseCaseFactory: editMediaLibraryListUseCaseFactory,
            confirmDialogViewModelFactory: confirmDialogViewModelFactory
        )
        
        let chooseDialogViewModelFactory = ChooseDialogViewModelImplFactory()
        let promptDialogViewModelFactory = PromptDialogViewModelImplFactory()
        
        let addMediaLibraryFolderFlowModelImplFactory = AddMediaLibraryFolderFlowModelImplFactory(
            editMediaLibraryListUseCaseFactory: editMediaLibraryListUseCaseFactory,
            promptDialogViewModelFactory: promptDialogViewModelFactory
        )
        
        let addMediaLibraryItemFlowModelFactory = AddMediaLibraryItemFlowModelImplFactory(
            chooseDialogViewModelFactory: chooseDialogViewModelFactory,
            importMediaFilesFlowModelFactory: importMediaFilesFlowModelFactory,
            addMediaLibraryFolderFlowModelFactory: addMediaLibraryFolderFlowModelImplFactory
        )
        
        let libraryFlowModelFactory = LibraryFlowModelImplFactory(
            viewModelFactory: libraryViewModelFactory,
            libraryItemFlowModelFactory: libraryItemFlowModelFactory,
            addMediaLibraryItemFlowModelFactory: addMediaLibraryItemFlowModelFactory,
            deleteMediaLibraryItemFlowModelFactory: deleteMediaLibraryItemFlowModelFactory
        )
        
        let editDictionaryItemUseCaseFactory = EditDictionaryItemUseCaseImplFactory(
            dictionaryRepository: dictionaryRepository,
            lemmatizer: LemmatizerImpl()
        )
        
        let loadDictionaryItemUseCaseFactory = LoadDictionaryItemUseCaseImplFactory(
            dictionaryRepository: dictionaryRepository
        )
        
        let editDictionaryItemViewModelFactory = EditDictionaryItemViewModelImplFactory(
            loadDictionaryItemUseCaseFactory: loadDictionaryItemUseCaseFactory,
            editDictionaryItemUseCaseFactory: editDictionaryItemUseCaseFactory
        )
        
        let addDictionaryItemFlowModelFactory = AddDictionaryItemFlowModelImplFactory(
            editDictionaryItemViewModelFactory: editDictionaryItemViewModelFactory
        )
        
        let editDictionaryListUseCaseFactory = EditDictionaryListUseCaseImplFactory(dictionaryRepository: dictionaryRepository)
        
        let deleteDictionaryItemFlowModelFactory = DeleteDictionaryItemFlowModelImplFactory(
            editDictionaryListUseCaseFactory: editDictionaryListUseCaseFactory
        )
        
        let dictionaryFlowModelFactory = DictionaryFlowModelImplFactory(
            viewModelFactory: dictionaryViewModelFactory,
            addDictionaryItemFlowModelFactory: addDictionaryItemFlowModelFactory,
            deleteDictionaryItemFlowModelFactory: deleteDictionaryItemFlowModelFactory
        )
        
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
        
        let confirmDialogViewFactory = ConfirmDialogViewControllerFactory()
        
        let chooseDialogViewControllerFactory = ChooseDialogViewControllerFactory()
        
        let deleteMediaLibraryItemFlowPresenterFactory = DeleteMediaLibraryItemFlowPresenterImplFactory(
            confirmDialogViewFactory: confirmDialogViewFactory
        )
        
        let promptDialogViewFactory = PromptDialogViewControllerFactory()
        
        let addMediaLibraryFolderFlowPresenterFactory = AddMediaLibraryFolderFlowPresenterImplFactory(
            promptFolderNameViewFactory: promptDialogViewFactory
        )
        
        let addMediaLibraryItemFlowPresenterFactory = AddMediaLibraryItemFlowPresenterImplFactory(
            chooseDialogViewFactory: chooseDialogViewControllerFactory,
            importMediaFilesFlowPresenterFactory: importMediaFilesFlowPresenterFactory,
            addMediaLibraryFolderFlowPresenterFactory: addMediaLibraryFolderFlowPresenterFactory
        )
        
        let libraryFlowPresenterFactory = LibraryFlowPresenterImplFactory(
            listViewFactory: MediaLibraryBrowserViewControllerFactory(),
            libraryItemFlowPresenterFactory: libraryItemFlowPresenterFactory,
            addMediaLibraryItemFlowPresenterFactory: addMediaLibraryItemFlowPresenterFactory,
            deleteMediaLibraryItemFlowPresenterFactory: deleteMediaLibraryItemFlowPresenterFactory
        )
        
        let addDictionaryItemFlowPresenterFactory = AddDictionaryItemFlowPresenterImplFactory(
            editDictionaryItemViewFactory: EditDictionaryItemViewControllerFactory()
        )
        
        let dictionaryFlowPresenterFactory = DictionaryFlowPresenterImplFactory(
            listViewFactory: DictionaryListBrowserViewControllerFactory(),
            addDictionaryItemFlowPresenterFactory: addDictionaryItemFlowPresenterFactory
        )
        
        return MainFlowPresenterImpl(
            mainFlowModel: flow,
            mainTabBarViewFactory: MainTabBarViewControllerFactory(),
            libraryFlowPresenterFactory: libraryFlowPresenterFactory,
            dictionaryFlowPresenterFactory: dictionaryFlowPresenterFactory
        )
    }
}
