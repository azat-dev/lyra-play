//
//  LibraryItemModuleFactoryImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 27.08.22.
//

import Foundation

//public final class LibraryItemModuleFactoryImpl: LibraryItemModuleFactory {
//    
//    private let viewModelFactory: LibraryItemViewModelFactory
//    private let viewFactory: LibraryItemViewFactory
//    
//    public init(viewModelFactory: LibraryItemViewModelFactory, viewFactory: LibraryItemViewFactory) {
//        
//        self.viewModelFactory = viewModelFactory
//        self.viewFactory = viewFactory
//    }
//    
//    public func create(
//        mediaId: UUID,
//        coordinator: LibraryItemCoordinatorInput,
//        viewModel: LibraryItemViewModel,
//        showMediaInfoUseCase: ShowMediaInfoUseCase,
//        currentPlayerStateUseCaseOutput: CurrentPlayerStateUseCaseOutput,
//        playMediaWithTranslationsUseCase: PlayMediaWithTranslationsUseCase,
//        importSubtitlesUseCase: ImportSubtitlesUseCase,
//        loadSubtitlesUseCase: LoadSubtitlesUseCase
//    ) -> PresentableModule<LibraryItemViewModel, LibraryItemView> {
//        
//        
//        let viewModel = viewModelFactory.create(
//            mediaId: mediaId,
//            coordinator: coordinator,
//            showMediaInfoUseCase: showMediaInfoUseCase,
//            currentPlayerStateUseCaseOutput: currentPlayerStateUseCaseOutput,
//            playMediaWithTranslationsUseCase: playMediaWithTranslationsUseCase,
//            importSubtitlesUseCase: importSubtitlesUseCase,
//            loadSubtitlesUseCase: loadSubtitlesUseCase
//        )
//        
//        let view = viewFactory.create(viewModel: viewModel)
//        
//        return PresentableModuleImpl(
//            view: view,
//            model: viewModel
//        )
//    }
//}
