//
//  ImportDictionaryArchiveFlowModelTests.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 30.01.2023.
//

import Foundation
import XCTest
import Mockingbird
import LyraPlay

class ImportDictionaryArchiveFlowModelTests: XCTestCase {

    typealias SUT = (
        flowModel: ImportDictionaryArchiveFlowModel,
        mainFlowModel: MainFlowModelMock,
        importDictionaryArchiveUseCaseFactory: ImportDictionaryArchiveUseCaseFactoryMock
    )

    // MARK: - Methods

    func createSUT(url: URL) -> SUT {

        let mainFlowModel = mock(MainFlowModel.self)

        let importDictionaryArchiveUseCaseFactory = mock(ImportDictionaryArchiveUseCaseFactory.self)
        
        let delegate = mock(ImportDictionaryArchiveFlowModelDelegate.self)

        let flowModel = ImportDictionaryArchiveFlowModelImpl(
            url: url,
            mainFlowModel: mainFlowModel,
            delegate: delegate,
            importDictionaryArchiveUseCaseFactory: importDictionaryArchiveUseCaseFactory
        )

        detectMemoryLeak(instance: flowModel)

        return (
            flowModel: flowModel,
            mainFlowModel: mainFlowModel,
            importDictionaryArchiveUseCaseFactory: importDictionaryArchiveUseCaseFactory
        )
    }
}
