//
//  DictionaryFlowModelTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 07.09.22.
//

import Foundation
import XCTest
import Mockingbird

import LyraPlay

class DictionaryFlowModelTests: XCTestCase {
    
    typealias SUT = (
        flow: DictionaryFlowModelImpl,
        listViewModel: DictionaryListBrowserViewModel
    )
    
    func createSUT(file: StaticString = #filePath, line: UInt = #line) -> SUT {
        
        let viewModel = mock(DictionaryListBrowserViewModel.self)
        let viewModelFactory = mock(DictionaryListBrowserViewModelFactory.self)
        
        given(viewModelFactory.create(delegate: any()))
            .willReturn(viewModel)
        
        
        let flow = DictionaryFlowModelImpl(
            viewModelFactory: viewModelFactory
        )
        
        detectMemoryLeak(instance: flow)
        
        releaseMocks(
            viewModel,
            viewModelFactory
        )
        
        return (
            flow,
            viewModel
        )
    }
}
