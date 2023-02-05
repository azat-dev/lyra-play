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

    typealias SUT = ApplicationFlowModel

    // MARK: - Methods

    func createSUT() -> SUT {
        
        let mainFlowModel = mock(MainFlowModel.self)
        
        let importDictionaryArchiveFlowModelFactory = mock(ImportDictionaryArchiveFlowModelFactory.self)

        let flowModel = ApplicationFlowModelImpl(
            mainFlowModel: mainFlowModel,
            importDictionaryArchiveFlowModelFactory: importDictionaryArchiveFlowModelFactory
        )

        detectMemoryLeak(instance: flowModel)

        return flowModel
    }
}
