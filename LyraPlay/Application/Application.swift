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
    
    private let settings: ApplicationSettings
    
    private lazy var appPresenter: MainFlowPresenter = {
        
        let appFlow = makeFlow()
        return makePresenter(flow: appFlow)
    } ()

    // MARK: - Properties
    
    private lazy var coreDataStore: CoreDataStore = {
        
        let url = NSPersistentContainer.defaultDirectoryURL()
            .appendingPathComponent(settings.dbFileName)
        
        return try! CoreDataStore(storeURL: url)
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
        
        
        let imagesDirectory = url.appendingPathComponent(settings.imagesFolderName, isDirectory: true)
        
        return try! LocalFilesRepository(baseDirectory: imagesDirectory)
    } ()
    
    private lazy var audioFilesRepository: FilesRepository = {
        
        let url = try! FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        )
        
        
        let mediaFilesDirectory = url.appendingPathComponent(settings.audioFilesFolderName, isDirectory: true)
        
        return try! LocalFilesRepository(baseDirectory: mediaFilesDirectory)
    } ()
    
    
    private lazy var showMediaInfoUseCase: ShowMediaInfoUseCase = {
        
        return ShowMediaInfoUseCaseImpl(
            mediaLibraryRepository: mediaLibraryRepository,
            imagesRepository: imagesRepository,
            defaultImage: UIImage(named: settings.coverPlaceholderName)!.pngData()!
        )
    } ()

    private lazy var subtitlesFilesRepository: FilesRepository = {
        
        let url = try! FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        )
        
        let subtitlesDirectory = url.appendingPathComponent(settings.subtitlesFolderName, isDirectory: true)
        
        return try! LocalFilesRepository(baseDirectory: subtitlesDirectory)
    } ()
        
    // MARK: - Initializers
    
    public init(settings: ApplicationSettings) {
        
        self.settings = settings
    }
    
    // MARK: - Methods
    
    public func start(container: UIWindow) {
        
        appPresenter.present(at: container)
    }
    
    func makeFlow() -> MainFlowModel {
        
        let subtitlesRepositoryFactory = CoreDataSubtitlesRepositoryFactory(coreDataStore: coreDataStore)
        
        let mainAudioSessionFactory = AudioSessionImplSingleInstanceFactory(mode: .mainAudio)
        let secondaryAudioSessionFactory = AudioSessionImplSingleInstanceFactory(mode: .promptAudio)
        
        let mainAudioPlayerFactory = AudioPlayerImplSingleInstanceFactory(audioSessionFactory: mainAudioSessionFactory)
        let secondaryAudioPlayerFactory = AudioPlayerImplSingleInstanceFactory(audioSessionFactory: secondaryAudioSessionFactory)
        
        let loadTrackUseCaseFactory = LoadTrackUseCaseImplFactory(
            mediaLibraryRepository: mediaLibraryRepository,
            audioFilesRepository: audioFilesRepository
        )
        
        let playMediaUseCaseFactory = PlayMediaUseCaseImplFactory(
            audioPlayerFactory: mainAudioPlayerFactory,
            loadTrackUseCaseFactory: loadTrackUseCaseFactory
        )
        
        let textSplitterFactory = TextSplitterImplFactory()
        
        let subtitlesParserFactory = SubtitlesParserImplFactory(
            parsers: [
                ".srt": SubRipFileFormatParserFactory(textSplitterFactory: textSplitterFactory),
                ".lrc": LyricsParserFactory(textSplitterFactory: textSplitterFactory)
            ]
        )
        
        let loadSubtitlesUseCaseFactory = LoadSubtitlesUseCaseImplFactory(
            subtitlesRepositoryFactory: subtitlesRepositoryFactory,
            subtitlesFiles: subtitlesFilesRepository,
            subtitlesParserFactory: subtitlesParserFactory
        )
        
        let playSubtitlesUseCaseFactory = PlaySubtitlesUseCaseImplFactory(
            subtitlesIteratorFactory: SubtitlesIteratorFactoryImpl(),
            schedulerFactory: SchedulerImplFactory(actionTimerFactory: ActionTimerFactoryImpl())
        )
        
        let playMediaWithSubtitlesUseCaseFactory = PlayMediaWithSubtitlesUseCaseImplFactory(
            playMediaUseCaseFactory: playMediaUseCaseFactory,
            playSubtitlesUseCaseFactory: playSubtitlesUseCaseFactory,
            loadSubtitlesUseCaseFactory: loadSubtitlesUseCaseFactory
        )
        
        let lemmatizerFactory = LemmatizerImplFactory()
        
        
        let provideTranslationsForSubtitlesUseCaseFactory = ProvideTranslationsForSubtitlesUseCaseImplFactory(
            dictionaryRepository: dictionaryRepository,
            textSplitterFactory: textSplitterFactory,
            lemmatizerFactory: lemmatizerFactory
        )
        
        let provideTranslationsToPlayUseCaseFactory = ProvideTranslationsToPlayUseCaseImplFactory(
            provideTranslationsForSubtitlesUseCaseFactory: provideTranslationsForSubtitlesUseCaseFactory
        )
        
        let textToSpeechConverterFactory = TextToSpeechConverterImplFactory();
        
        let pronounceTranslationsUseCaseFactory = PronounceTranslationsUseCaseImplFactory(
            textToSpeechConverterFactory: textToSpeechConverterFactory,
            audioPlayerFactory: mainAudioPlayerFactory
        )
        
        let pronounceTranslationsUseCase = pronounceTranslationsUseCaseFactory.create()
        
        let playMediaWithTranslationsUseCaseFactory = PlayMediaWithTranslationsUseCaseImplFactory(
            playMediaWithSubtitlesUseCaseFactory: playMediaWithSubtitlesUseCaseFactory,
            playSubtitlesUseCaseFactory: playSubtitlesUseCaseFactory,
            provideTranslationsToPlayUseCaseFactory: provideTranslationsToPlayUseCaseFactory,
            pronounceTranslationsUseCase: pronounceTranslationsUseCase
        )
        
        let showMediaInfoUseCaseFactory = ShowMediaInfoUseCaseImplFactory(
            mediaLibraryRepository: mediaLibraryRepository,
            imagesRepository: imagesRepository,
            defaultImage: UIImage(named: settings.coverPlaceholderName)!.pngData()!
        )
        
        let playMediaWithInfoUseCaseFactory = PlayMediaWithInfoUseCaseImplSingleInstanceFactory(
            playMediaWithTranslationsUseCaseFactory: playMediaWithTranslationsUseCaseFactory,
            showMediaInfoUseCaseFactory: showMediaInfoUseCaseFactory
        )
        
        let currentPlayerStateViewModelFactory = CurrentPlayerStateViewModelImplFactory(
            playMediaUseCaseFactory: playMediaWithInfoUseCaseFactory
        )
        
        let mainTabBarViewModelFactory = MainTabBarViewModelImplFactory(
            currentPlayerStateViewModelFactory: currentPlayerStateViewModelFactory
        )

        let browseMediaLibraryUseCaseFactory = BrowseMediaLibraryUseCaseImplFactory(
            mediaLibraryRepository: mediaLibraryRepository,
            imagesRepository: imagesRepository
        )
        
        let tagsParserFactory = TagsParserFactoryImpl()
        
        let imporAudioFileUseCaseFactory = ImportAudioFileUseCaseImplFactory(
            mediaLibraryRepository: mediaLibraryRepository,
            audioFilesRepository: audioFilesRepository,
            imagesRepository: imagesRepository,
            tagsParserFactory: tagsParserFactory,
            fileNameGenerator: ImportAudioFileUseCaseFileNameGeneratorImpl()
        )
        
        let importSubtitlesUseCaseFactory = ImportSubtitlesUseCaseImplFactory(
            supportedExtensions: settings.supportedSubtitlesExtensions,
            subtitlesRepositoryFactory: subtitlesRepositoryFactory,
            subtitlesParserFactory: subtitlesParserFactory,
            subtitlesFilesRepository: subtitlesFilesRepository
        )

        let libraryViewModelFactory = MediaLibraryBrowserViewModelImplFactory(
            browseMediaLibraryUseCaseFactory: browseMediaLibraryUseCaseFactory,
            importAudioFileUseCaseFactory: imporAudioFileUseCaseFactory
        )
        
        let libraryFileViewModelFactory = LibraryItemViewModelImplFactory(
            showMediaInfoUseCase: showMediaInfoUseCase,
            playMediaUseCaseFactory: playMediaWithInfoUseCaseFactory
        )
        
        let browseDictionaryUseCase = BrowseDictionaryUseCaseImpl(
            dictionaryRepository: dictionaryRepository
        )
        
        let pronounceTextUseCaseFactory = PronounceTextUseCaseImplFactory(
            textToSpeechConverterFactory: textToSpeechConverterFactory,
            audioPlayerFactory: secondaryAudioPlayerFactory
        )
        
        let dictionaryViewModelFactory = DictionaryListBrowserViewModelImplFactory(
            browseDictionaryUseCase: browseDictionaryUseCase,
            pronounceTextUseCaseFactory: pronounceTextUseCaseFactory,
            dictionaryListBrowserItemViewModelFactory: DictionaryListBrowserItemViewModelImplFactory()
        )
        
        let attachingSubtitlesProgressViewModelFactory = AttachingSubtitlesProgressViewModelImplFactory()
        
        let filesPickerViewModelFactory = FilesPickerViewModelImplFactory()
        
        let attachSubtitlesFlowModelFactory = AttachSubtitlesFlowModelImplFactory(
            allowedDocumentTypes: settings.allowedSubtitlesDocumentTypes,
            subtitlesPickerViewModelFactory: filesPickerViewModelFactory,
            attachingSubtitlesProgressViewModelFactory: attachingSubtitlesProgressViewModelFactory,
            importSubtitlesUseCaseFactory: importSubtitlesUseCaseFactory
        )
        
        let libraryFileFlowModelFactory = LibraryFileFlowModelImplFactory(
            libraryItemViewModelFactory: libraryFileViewModelFactory,
            attachSubtitlesFlowModelFactory: attachSubtitlesFlowModelFactory
        )
        
        let importMediaFilesFlowModelFactory = ImportMediaFilesFlowModelImplFactory(
            allowedDocumentTypes: settings.allowedMediaDocumentTypes,
            filesPickerViewModelFactory: filesPickerViewModelFactory,
            importAudioFileUseCaseFactory: imporAudioFileUseCaseFactory
        )
        
        let manageSubtitlesUseCaseFactory = ManageSubtitlesUseCaseImplFactory(
            subtitlesRepositoryFactory: subtitlesRepositoryFactory,
            subtitlesFilesRepository: subtitlesFilesRepository
        )
        
        let editMediaLibraryListUseCaseFactory = EditMediaLibraryListUseCaseImplFactory(
            mediaLibraryRepository: mediaLibraryRepository,
            mediaFilesRepository: audioFilesRepository,
            manageSubtitlesUseCaseFactory: manageSubtitlesUseCaseFactory,
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
        
        let libraryFolderFlowModelFactory = LibraryFolderFlowModelImplFactory(
            viewModelFactory: libraryViewModelFactory,
            libraryFileFlowModelFactory: libraryFileFlowModelFactory,
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
        
        let dictionaryExporter = DictionaryExporterImpl()
        
        let exportDictionaryUseCaseFactory = ExportDictionaryUseCaseImplFactory(
            dictionaryRepository: dictionaryRepository,
            dictionaryExporter: dictionaryExporter
        )
        
        let provideFileForSharingUseCaseFactory = ProvideExportedDictionaryFileForSharingUseCaseFactory(
            exportDictionaryUseCaseFactory: exportDictionaryUseCaseFactory
        )
        
        let tempURLProviderFactory = TempURLProviderImplFactory(fileManager: FileManager.default)
        
        let fileSharingViewModelFactory = FileSharingViewModelImplFactory(
            provideFileForSharingUseCaseFactory: provideFileForSharingUseCaseFactory,
            tempURLProviderFactory: tempURLProviderFactory
        )
        
        let exportDictionaryFlowModelFactory = ExportDictionaryFlowModelImplFactory(
            outputFileName: settings.defaultDictionaryArchiveName,
            fileSharingViewModelFactory: fileSharingViewModelFactory
        )
        
        let dictionaryFlowModelFactory = DictionaryFlowModelImplFactory(
            viewModelFactory: dictionaryViewModelFactory,
            addDictionaryItemFlowModelFactory: addDictionaryItemFlowModelFactory,
            deleteDictionaryItemFlowModelFactory: deleteDictionaryItemFlowModelFactory,
            exportDictionaryFlowModelFactory: exportDictionaryFlowModelFactory
        )
        
        let subtitlesPresenterViewModelFactory = SubtitlesPresenterViewModelImplFactory()
        
        let currentPlayerStateDetailsViewModelFactory = CurrentPlayerStateDetailsViewModelImplFactory(
            playMediaUseCaseFactory: playMediaWithInfoUseCaseFactory,
            subtitlesPresenterViewModelFactory: subtitlesPresenterViewModelFactory
        )
        
        let currentPlayerStateDetailsFlowModelFactory = CurrentPlayerStateDetailsFlowModelImplFactory(
            currentPlayerStateDetailsViewModelFactory: currentPlayerStateDetailsViewModelFactory
        )
        
        return MainFlowModelImpl(
            mainTabBarViewModelFactory: mainTabBarViewModelFactory,
            libraryFlowModelFactory: libraryFolderFlowModelFactory,
            dictionaryFlowModelFactory: dictionaryFlowModelFactory,
            currentPlayerStateDetailsFlowModelFactory: currentPlayerStateDetailsFlowModelFactory
        )
    }
    
    func makePresenter(flow: MainFlowModel) -> MainFlowPresenter {
        
        let filesPickerViewFactory = FilesPickerViewControllerFactory()
        
        let attachSubtitlesFlowPresenterFactory = AttachSubtitlesFlowPresenterImplFactory(
            subtitlesPickerViewFactory: filesPickerViewFactory,
            attachingSubtitlesProgressViewFactory: AttachingSubtitlesProgressViewControllerFactory()
        )
        
        let libraryItemFlowPresenterFactory = LibraryFileFlowPresenterImplFactory(
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
        
        let libraryFolderFlowPresenterFactory = LibraryFolderFlowPresenterImplFactory(
            listViewFactory: MediaLibraryBrowserViewControllerFactory(),
            libraryItemFlowPresenterFactory: libraryItemFlowPresenterFactory,
            addMediaLibraryItemFlowPresenterFactory: addMediaLibraryItemFlowPresenterFactory,
            deleteMediaLibraryItemFlowPresenterFactory: deleteMediaLibraryItemFlowPresenterFactory
        )
        
        let addDictionaryItemFlowPresenterFactory = AddDictionaryItemFlowPresenterImplFactory(
            editDictionaryItemViewFactory: EditDictionaryItemViewControllerFactory()
        )
        
        let fileSharingViewControllerFactory = FileSharingViewControllerFactory()
        
        let exportDictionaryFlowPresenterFactory = ExportDictionaryFlowPresenterImplFactory(
            fileSharingViewControllerFactory: fileSharingViewControllerFactory
        )
        
        let dictionaryFlowPresenterFactory = DictionaryFlowPresenterImplFactory(
            listViewFactory: DictionaryListBrowserViewControllerFactory(),
            addDictionaryItemFlowPresenterFactory: addDictionaryItemFlowPresenterFactory,
            exportDictionaryFlowPresenterFactory: exportDictionaryFlowPresenterFactory
        )
        
        let currentPlayerStateDetailsViewControllerFactory = CurrentPlayerStateDetailsViewControllerFactory()
        
        let currentPlayerStateDetailsFlowPresenterFactory = CurrentPlayerStateDetailsFlowPresenterImplFactory(
            currentPlayerStateDetailsViewControllerFactory: currentPlayerStateDetailsViewControllerFactory
        )
        
        return MainFlowPresenterImpl(
            mainFlowModel: flow,
            mainTabBarViewFactory: MainTabBarViewControllerFactory(),
            libraryFlowPresenterFactory: libraryFolderFlowPresenterFactory,
            dictionaryFlowPresenterFactory: dictionaryFlowPresenterFactory,
            currentPlayerStateDetailsFlowPresenterFactory: currentPlayerStateDetailsFlowPresenterFactory
        )
    }
}
