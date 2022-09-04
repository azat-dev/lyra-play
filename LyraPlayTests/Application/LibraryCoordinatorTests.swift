//
//  LibraryCoordinatorTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 26.08.22.
//

import Foundation
import XCTest
import LyraPlay
import Mockingbird

//class LibraryCoordinatorTests: XCTestCase {
//    
//    typealias SUT = LibraryCoordinator
//    
//    func createSUT(file: StaticString = #filePath, line: UInt = #line) -> SUT {
//        
//        let browseUseCase = mock(BrowseAudioLibraryUseCase.self)
//        let importUseCase = mock(ImportAudioFileUseCase.self)
//        
//        let moduleFactory = LibraryModuleFactoryMock()
//        
//        let coordinator = LibraryCoordinatorImpl(
//            moduleFactory: moduleFactory,
//            browseAudioLibraryUseCaseFactory: { browseUseCase },
//            importAudioFileUseCaseFactory: { importUseCase }
//        )
//        
//        detectMemoryLeak(instance: coordinator, file: file, line: line)
//        return coordinator
//    }
//    
//    func test_start() {
//        
//        // Given
//        let sut = createSUT()
//        let container = mock(StackPresentationContainer.self)
//        
//        // When
//        sut.start(at: container)
//        
//        // Then
//        verify(container.setRoot(any())).wasCalled()
//    }
//}
//
//// MARK: - Mocks
//
//private class LibraryModuleFactoryMock: LibraryModuleFactory {
//    
//    func create(coordinator: LibraryCoordinator, browseUseCase: BrowseAudioLibraryUseCase, importFileUseCase: ImportAudioFileUseCase) -> PresentableModuleImpl<AudioFilesBrowserViewModel> {
//        
//        return PresentableModuleImpl(
//            view: UIViewController(nibName: nil, bundle: nil),
//            model: mock(AudioFilesBrowserViewModel.self)
//        )
//    }
//}
