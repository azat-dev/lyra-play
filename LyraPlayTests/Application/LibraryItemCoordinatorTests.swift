//
//  LibraryItemCoordinatorTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 27.08.22.
//

import Foundation
import XCTest
import LyraPlay
import Mockingbird

class LibraryItemCoordinatorTests: XCTestCase {
    
    typealias SUT = LibraryCoordinator
    
    func createSUT(file: StaticString = #filePath, line: UInt = #line) -> SUT {
        
        let browseUseCase = mock(BrowseAudioLibraryUseCase.self)
        let importUseCase = mock(ImportAudioFileUseCase.self)
        
        let moduleFactory = LibraryItemModuleFactoryMoc()
        
        let coordinator = LibraryItemCoordinatorImpl(
            moduleFactory: moduleFactory,
            browseAudioLibraryUseCaseFactory: { browseUseCase },
            importAudioFileUseCaseFactory: { importUseCase }
        )
        
        detectMemoryLeak(instance: coordinator, file: file, line: line)
        return coordinator
    }
    
    func test_start() {
        
        // Given
        let sut = createSUT()
        let container = mock(StackPresentationContainer.self)
        
        // When
        sut.start(at: container)
        
        // Then
        verify(container.setRoot(any())).wasCalled()
    }
}

class LibraryModuleFactoryMock2: LibraryItemMod {
    
    func create(coordinator: LibraryCoordinator, browseUseCase: BrowseAudioLibraryUseCase, importFileUseCase: ImportAudioFileUseCase) -> PresentableModuleImpl<AudioFilesBrowserViewModel> {
        
        let viewModel = mock(AudioFilesBrowserViewModel.self)
        
        return PresentableModuleImpl(
            view: UIViewController(nibName: nil, bundle: nil),
            model: viewModel as AudioFilesBrowserViewModel
        )
    }
}
