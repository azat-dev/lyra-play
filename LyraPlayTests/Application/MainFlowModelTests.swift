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
    
    func createSUT(file: StaticString = #filePath, line: UInt = #line) -> SUT {
        
        let libraryFlowModel = mock(LibraryFlowModel.self)
        let libraryFlowModelFactory = mock(LibraryFlowModelFactory.self)
        
        given(libraryFlowModelFactory.create())
            .willReturn(libraryFlowModel)
        
        let mainTabBarViewModel = mock(MainTabBarViewModel.self)
        let mainTabBarViewModelFactory = mock(MainTabBarViewModelFactory.self)
        
        given(mainTabBarViewModelFactory.create(delegate: any()))
            .willReturn(mainTabBarViewModel)
        
        let flow = MainFlowModelImpl(
            mainTabBarViewModelFactory: mainTabBarViewModelFactory,
            libraryFlowModelFactory: libraryFlowModelFactory
        )
        
        detectMemoryLeak(instance: flow)
        addTeardownBlock {
            reset(
                mainTabBarViewModel,
                mainTabBarViewModelFactory,
                libraryFlowModel,
                libraryFlowModelFactory
            )
        }
        
        return (
            flow,
            mainTabBarViewModel
        )
    }
    
    func test_selectLibraryTab() async throws {
        
        // Given
        let sut = createSUT()

        let sequence = expectSequence([true, false])
        let disposible = sut.flow.libraryFlow.sink { sequence.fulfill(with: $0 == nil) }
        
        // When
        sut.flow.runLibraryFlow()
        
        // Then
        sequence.wait(timeout: 1, enforceOrder: true)
        
        disposible.cancel()
    }
}

