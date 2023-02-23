//
//  ApplicationFlowModelImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 28.01.2023.
//

import Foundation
import CoreData
import UIKit

public final class ApplicationFlowModelImplFactory: ApplicationFlowModelFactory {
    
    // MARK: - Properties
    
    private let settings: ApplicationSettings
    
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

    public func make() -> ApplicationFlowModel {
        
        let subtitlesRepositoryFactory = CoreDataSubtitlesRepositoryFactory(coreDataStore: coreDataStore)
        
        let mainAudioSessionFactory = AudioSessionImplSingleInstanceFactory(mode: .mainAudio)
        let secondaryAudioSessionFactory = AudioSessionImplSingleInstanceFactory(mode: .promptAudio)
        
        let mainAudioPlayerFactory = AudioPlayerImplSingleInstanceFactory(audioSessionFactory: mainAudioSessionFactory)
        let secondaryAudioPlayerFactory = AudioPlayerImplSingleInstanceFactory(audioSessionFactory: secondaryAudioSessionFactory)
        
        let loadTrackUseCaseFactory = LoadTrackUseCaseImplFactory(
            mediaLibraryRepository: mediaLibraryRepository,
            audioFilesRepository: audioFilesRepository
        )
        
        let initialPlayMediaUseCaseStateControllerFactory = InitialPlayMediaUseCaseStateControllerImplFactory()
        
        let loadingPlayMediaUseCaseStateControllerFactory = LoadingPlayMediaUseCaseStateControllerImplFactory(
            loadTrackUseCaseFactory: loadTrackUseCaseFactory,
            audioPlayerFactory: mainAudioPlayerFactory
        )
        
        let loadedPlayMediaUseCaseStateControllerFactory = LoadedPlayMediaUseCaseStateControllerImplFactory()
        
        let failedLoadPlayMediaUseCaseStateControllerFactory = FailedLoadPlayMediaUseCaseStateControllerImplFactory()
        
        let playingPlayMediaUseCaseStateControllerFactory = PlayingPlayMediaUseCaseStateControllerImplFactory()
        
        let pausedPlayMediaUseCaseStateControllerFactory = PausedPlayMediaUseCaseStateControllerImplFactory()
        
        let finishedPlayMediaUseCaseStateControllerFactory = FinishedPlayMediaUseCaseStateControllerImplFactory()
        
        let playMediaUseCaseFactory = PlayMediaUseCaseImplFactory(
            initialStateFactory: initialPlayMediaUseCaseStateControllerFactory,
            loadingStateFactory: loadingPlayMediaUseCaseStateControllerFactory,
            loadedStateFactory: loadedPlayMediaUseCaseStateControllerFactory,
            failedLoadStateFactory: failedLoadPlayMediaUseCaseStateControllerFactory,
            playingStateFactory: playingPlayMediaUseCaseStateControllerFactory,
            pausedStateFactory: pausedPlayMediaUseCaseStateControllerFactory,
            finishedStateFactory: finishedPlayMediaUseCaseStateControllerFactory
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
            schedulerFactory: TimelineSchedulerImplFactory(actionTimerFactory: ActionTimerFactoryImpl())
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
        
        let pronounceTranslationsUseCase = pronounceTranslationsUseCaseFactory.make()
        
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
        
        let mainFlowModel = MainFlowModelImpl(
            mainTabBarViewModelFactory: mainTabBarViewModelFactory,
            libraryFlowModelFactory: libraryFolderFlowModelFactory,
            dictionaryFlowModelFactory: dictionaryFlowModelFactory,
            currentPlayerStateDetailsFlowModelFactory: currentPlayerStateDetailsFlowModelFactory
        )
        
        let deepLinksHandlerFactory = DeepLinksHandlerFlowModelImplFactory(
            dictionaryArchiveExtension: settings.dictionaryArchiveExtension
        )
        
        let importDictionaryArchiveUseCaseFactory = ImportDictionaryArchiveUseCaseImplFactory(
            dictionaryRepository: dictionaryRepository,
            dictionaryArchiveParserFactory: DictionaryArchiveParserImplFactory()
        )
        
        let importDictionaryArchiveFlowModelFactory = ImportDictionaryArchiveFlowModelImplFactory(
            importDictionaryArchiveUseCaseFactory: importDictionaryArchiveUseCaseFactory
        )
        
        return ApplicationFlowModelImpl(
            mainFlowModel: mainFlowModel,
            importDictionaryArchiveFlowModelFactory: importDictionaryArchiveFlowModelFactory
        )
    }
}
