//
//  ApplicationFlowPresenterImplFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 28.01.2023.
//

import Foundation

public final class ApplicationFlowPresenterImplFactory: ApplicationFlowPresenterFactory {

    // MARK: - Initializers

    public init() {}

    // MARK: - Methods

    public func make(for flowModel: ApplicationFlowModel) -> ApplicationFlowPresenter {

        
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
        
        let mainFlowPresenterFactory = MainFlowPresenterImplFactory(
            mainTabBarViewFactory: MainTabBarViewControllerFactory(),
            libraryFlowPresenterFactory: libraryFolderFlowPresenterFactory,
            dictionaryFlowPresenterFactory: dictionaryFlowPresenterFactory,
            currentPlayerStateDetailsFlowPresenterFactory: currentPlayerStateDetailsFlowPresenterFactory
        )
        
        return ApplicationFlowPresenterImpl(
            flowModel: flowModel,
            mainFlowPresenterFactory: mainFlowPresenterFactory
        )
    }
}
