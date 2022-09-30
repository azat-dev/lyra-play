//
//  MainFlowModelTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 07.09.22.
//

import Foundation
import XCTest
import Mockingbird

import LyraPlay

class MainFlowModelTests: XCTestCase {
    
    typealias SUT = (
        flow: MainFlowModelImpl,
        mainTabBarViewModel: MainTabBarViewModelMock
    )
    
    func createSUT(folderId: UUID?, file: StaticString = #filePath, line: UInt = #line) -> SUT {
        
        let libraryFlowModel = mock(LibraryFolderFlowModel.self)
        let libraryFlowModelFactory = mock(LibraryFolderFlowModelFactory.self)
        
        given(libraryFlowModelFactory.create(folderId: folderId))
            .willReturn(libraryFlowModel)
        
        let dictionaryFlowModel = mock(DictionaryFlowModel.self)
        let dictionaryFlowModelFactory = mock(DictionaryFlowModelFactory.self)
        
        given(dictionaryFlowModelFactory.create())
            .willReturn(dictionaryFlowModel)
        
        
        let currentPlayerStateDetailsFlowModel = mock(CurrentPlayerStateDetailsFlowModel.self)
        let currentPlayerStateDetailsFlowModelFactory = mock(CurrentPlayerStateDetailsFlowModelFactory.self)
        
        given(currentPlayerStateDetailsFlowModelFactory.create(delegate: any()))
            .willReturn(currentPlayerStateDetailsFlowModel)
        
        let mainTabBarViewModel = mock(MainTabBarViewModel.self)
        let mainTabBarViewModelFactory = mock(MainTabBarViewModelFactory.self)
        
        given(mainTabBarViewModelFactory.create(delegate: any()))
            .willReturn(mainTabBarViewModel)
        
        let flow = MainFlowModelImpl(
            mainTabBarViewModelFactory: mainTabBarViewModelFactory,
            libraryFlowModelFactory: libraryFlowModelFactory,
            dictionaryFlowModelFactory: dictionaryFlowModelFactory,
            currentPlayerStateDetailsFlowModelFactory: currentPlayerStateDetailsFlowModelFactory
        )
        
        detectMemoryLeak(instance: flow)

        releaseMocks(
            mainTabBarViewModel,
            mainTabBarViewModelFactory,
            libraryFlowModel,
            libraryFlowModelFactory,
            dictionaryFlowModel,
            dictionaryFlowModelFactory,
            currentPlayerStateDetailsFlowModel,
            currentPlayerStateDetailsFlowModelFactory
        )
        
        return (
            flow,
            mainTabBarViewModel
        )
    }
    
    func test_runLibraryFlow() async throws {
        
        // Given
        let sut = createSUT(folderId: nil)
        
        let sequence = expectSequence([true, false])
        let disposible = sut.flow.libraryFlow.sink { sequence.fulfill(with: $0 == nil) }
        
        // When
        sut.flow.runLibraryFlow()
        sut.flow.runLibraryFlow()
        
        // Then
        sequence.wait(timeout: 1, enforceOrder: true)
        
        disposible.cancel()
    }
    
    func test_runDictionaryFlow() async throws {
        
        // Given
        let sut = createSUT(folderId: nil)
        
        let dictionaryFlowSequence = watch(sut.flow.dictionaryFlow, mapper: { $0 == nil })
        
        // When
        sut.flow.runDictionaryFlow()
        sut.flow.runDictionaryFlow()
        
        // Then
        dictionaryFlowSequence.expect([true, false])
    }
    
    func test_runOpenCurrentPlayerStateDetailsFlow() async throws {
        
        // Given
        let sut = createSUT(folderId: nil)
        
        let currentPlayerStateDetailsPromise = watch(sut.flow.currentPlayerStateDetailsFlow, mapper: { $0 == nil })
        
        // When
        sut.flow.runOpenCurrentPlayerStateDetailsFlow()
        sut.flow.runOpenCurrentPlayerStateDetailsFlow()
        
        // Then
        currentPlayerStateDetailsPromise.expect([true, false])
    }
}
