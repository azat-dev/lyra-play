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
        
        let addFlowModel = mock(AddDictionaryItemFlowModel.self)
        let addDictionaryItemFlowModelFactory = mock(AddDictionaryItemFlowModelFactory.self)
        let delegate = mock(AddDictionaryItemFlowModelDelegate.self)
        
        let deleteDictionaryItemFlowModelFactory = mock(DeleteDictionaryItemFlowModelFactory.self)
        
        given(addDictionaryItemFlowModelFactory.create(originalText: "", delegate: delegate))
            .willReturn(addFlowModel)
        
        let flow = DictionaryFlowModelImpl(
            viewModelFactory: viewModelFactory,
            addDictionaryItemFlowModelFactory: addDictionaryItemFlowModelFactory,
            deleteDictionaryItemFlowModelFactory: deleteDictionaryItemFlowModelFactory
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
