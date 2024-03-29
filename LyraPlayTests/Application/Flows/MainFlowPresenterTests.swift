////
////  MainFlowPresenterTests.swift
////  LyraPlayTests
////
////  Created by Azat Kaiumov on 08.09.22.
////
//
//import Foundation
//import XCTest
//import Combine
//import Mockingbird
//import UIKit
//
//import LyraPlay
//
//class MainFlowPresenterTests: XCTestCase {
//    
//    typealias SUT = (
//        presenter: MainFlowPresenter,
//        flow: MainFlowModelMock,
//        mainTabBarView: MainTabBarViewController,
//        
//        libraryFlowPresenter: LibraryFlowPresenterMock,
//        libraryContainer: UINavigationController,
//        libraryFlowSubject: CurrentValueSubject<LibraryFlowModel?, Never>,
//        
//        dictionaryFlowPresenter: UINavigationController,
//        dictionaryContainer: UINavigationController,
//        dictionaryFlowSubject: CurrentValueSubject<DictionaryFlowModel?, Never>
//    )
//    
//    func createSUT(file: StaticString = #filePath, line: UInt = #line) -> SUT {
//        
//        let viewModel = mock(MainTabBarViewModel.self)
//        let mainTabBarView = mock(MainTabBarViewController.self)
//        
//        let libraryContainer = mock(UINavigationController.self)
//        let dictionaryContainer = mock(UINavigationController.self)
//        
//        given(mainTabBarView.libraryContainer)
//            .willReturn(libraryContainer)
//        
//        given(mainTabBarView.dictionaryContainer)
//            .willReturn(dictionaryContainer)
//        
//        let mainTabBarViewFactory = mock(MainTabBarViewFactory.self)
//        
//        given(mainTabBarViewFactory.make(viewModel: viewModel))
//            .willReturn(mainTabBarView)
//        
//        let flow = mock(MainFlowModel.self)
//        
//        given(flow.mainTabBarViewModel)
//            .willReturn(viewModel)
//
//
//        let libraryFlowSubject = CurrentValueSubject<LibraryFlowModel?, Never>(nil)
//        
//        given(flow.libraryFlow)
//            .willReturn(libraryFlowSubject)
//        
//        let libraryFlowPresenter = mock(LibraryFlowPresenter.self)
//        
//        let libraryFlowPresenterFactory = mock(LibraryFlowPresenterFactory.self)
//        given(libraryFlowPresenterFactory.make(for: any()))
//            .willReturn(libraryFlowPresenter)
//        
//
//        let dictionaryFlowSubject = CurrentValueSubject<DictionaryFlowModel?, Never>(nil)
//        
//        given(flow.dictionaryFlow)
//            .willReturn(dictionaryFlowSubject)
//        
//        let dictionaryFlowPresenter = mock(DictionaryFlowPresenter.self)
//        
//        let dictionaryFlowPresenterFactory = mock(DictionaryFlowPresenterFactory.self)
//        given(dictionaryFlowPresenterFactory.make(for: any()))
//            .willReturn(dictionaryFlowPresenter)
//
//        let presenter = MainFlowPresenterImpl(
//            mainFlowModel: flow,
//            mainTabBarViewFactory: mainTabBarViewFactory,
//            libraryFlowPresenterFactory: libraryFlowPresenterFactory,
//            dictionaryFlowPresenterFactory: dictionaryFlowPresenterFactory
//        )
//        
//        detectMemoryLeak(instance: presenter)
//
//        releaseMocks(
//            flow,
//            viewModel,
//            mainTabBarView,
//            mainTabBarViewFactory,
//            
//            libraryFlowPresenterFactory,
//            libraryFlowPresenter,
//            libraryContainer,
//            
//            dictionaryFlowPresenterFactory,
//            dictionaryFlowPresenter,
//            dictionaryContainer
//        )
//        
//        return (
//            presenter,
//            flow,
//            mainTabBarView,
//            
//            libraryFlowPresenter,
//            libraryContainer,
//            libraryFlowSubject,
//            
//            dictionaryFlowPresenter,
//            dictionaryContainer,
//            dictionaryFlowSubject
//        )
//    }
//    
//    func test_setRoot() async throws {
//        
//        // Given
//        let sut = createSUT()
//        let window = mock(WindowContainer.self)
//        
//        // When
//        sut.presenter.present(at: window)
//        
//        // Then
//        verify(window.setRoot(sut.mainTabBarView))
//            .wasCalled(1)
//    }
//    
//    func test_present_library_flow() async throws {
//        
//        // Given
//        let sut = createSUT()
//
//        let window = mock(WindowContainer.self)
//        sut.presenter.present(at: window)
//        
//        let libraryFlow = mock(LibraryFlowModel.self)
//        
//        // When
//        sut.libraryFlowSubject.value = libraryFlow
//        
//        // Then
//        verify(sut.libraryFlowPresenter.present(at: any()))
//            .wasCalled(1)
//    }
//    
//    func test_present_dictionary_flow() async throws {
//        
//        // Given
//        let sut = createSUT()
//
//        let window = mock(WindowContainer.self)
//        sut.presenter.present(at: window)
//        
//        let dictionaryFlow = mock(DictionaryFlowModel.self)
//        
//        // When
//        sut.dictionaryFlowSubject.value = dictionaryFlow
//        
//        // Then
//        verify(sut.dictionaryFlowPresenter.present(at: any()))
//            .wasCalled(1)
//    }
//}
