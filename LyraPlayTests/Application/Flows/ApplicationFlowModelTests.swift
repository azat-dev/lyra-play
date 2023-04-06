//
//  ApplicationFlowModelTests.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 28.01.2023.
//

import Foundation
import XCTest
import Mockingbird
import LyraPlay

class ApplicationFlowModelTests: XCTestCase {

    typealias SUT = (
        flowModel: ApplicationFlowModel,
        importDictionaryArchiveFlowModelFactory: ImportDictionaryArchiveFlowModelFactory,
        importDictionaryArchiveFlowModel: ImportDictionaryArchiveFlowModel
    )

    // MARK: - Methods

    func createSUT() -> SUT {
        
        let mainFlowModel = mock(MainFlowModel.self)
        
        let importDictionaryArchiveFlowModelFactory = mock(ImportDictionaryArchiveFlowModelFactory.self)
        
        let importDictionaryArchiveFlowModel = mock(ImportDictionaryArchiveFlowModel.self)
            
        given(
            importDictionaryArchiveFlowModelFactory.make(
                url: any(),
                mainFlowModel: any(),
                delegate: any()
            )
        ).willReturn(importDictionaryArchiveFlowModel)

        let flowModel = ApplicationFlowModelImpl(
            mainFlowModel: mainFlowModel,
            importDictionaryArchiveFlowModelFactory: importDictionaryArchiveFlowModelFactory
        )

        detectMemoryLeak(instance: flowModel)
        
        releaseMocks(
            importDictionaryArchiveFlowModelFactory,
            importDictionaryArchiveFlowModel
        )

        return (
            flowModel,
            importDictionaryArchiveFlowModelFactory,
            importDictionaryArchiveFlowModel
        )
    }
    
    func test_runImportDictionaryArchiveFlow() async {
        
        // Given
        let sut = createSUT()
        let dictionaryArchiveFileUrl = URL(string: "https://someurl.com")!
        
        given(sut.importDictionaryArchiveFlowModel.start())
            .willReturn()
        
        // When
        sut.flowModel.runImportDictionaryArchiveFlow(url: dictionaryArchiveFileUrl)
        
        // Then
        XCTAssertNotNil(sut.flowModel.importDictionaryArchiveFlowModel.value)
        
        verify(
            sut.importDictionaryArchiveFlowModelFactory.make(
                url: dictionaryArchiveFileUrl,
                mainFlowModel: secondArg(any()),
                delegate: thirdArg(any())
            )
        ).wasCalled(1)
        
        verify(sut.importDictionaryArchiveFlowModel.start())
            .wasCalled(1)
    }
}
