//
//  LibraryFlowModelTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 07.09.22.
//

import Foundation
import XCTest
import Mockingbird

import LyraPlay

class LibraryFlowModelTests: XCTestCase {
    
    typealias SUT = (
        flow: LibraryFlowModelImpl,
        listViewModel: AudioFilesBrowserViewModelMock
    )
    
    func createSUT(file: StaticString = #filePath, line: UInt = #line) -> SUT {
        
        let viewModel = mock(AudioFilesBrowserViewModel.self)
        let viewModelFactory = mock(AudioFilesBrowserViewModelFactory.self)
        
        given(viewModelFactory.create(delegate: any()))
            .willReturn(viewModel)
        
        
        let flow = LibraryFlowModelImpl(
            viewModelFactory: viewModelFactory
        )
        
        detectMemoryLeak(instance: flow)
        
        addTeardownBlock {
            reset(
                viewModel,
                viewModelFactory
            )
        }
        
        return (
            flow,
            viewModel
        )
    }
}
