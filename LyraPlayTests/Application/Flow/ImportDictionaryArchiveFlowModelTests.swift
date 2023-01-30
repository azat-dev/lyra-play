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
        mainTabBarViewModel: MainTabBarViewModelMock,
        importDictionaryArchiveUseCaseFactory: ImportDictionaryArchiveUseCaseFactoryMock
    )

    // MARK: - Methods

    func createSUT() -> SUT {

        let mainTabBarViewModel = mock(MainTabBarViewModel.self)

        let importDictionaryArchiveUseCaseFactory = mock(ImportDictionaryArchiveUseCaseFactory.self)

        let flowModel = ImportDictionaryArchiveFlowModelImpl(
            mainTabBarViewModel: mainTabBarViewModel,
            importDictionaryArchiveUseCaseFactory: importDictionaryArchiveUseCaseFactory
        )

        detectMemoryLeak(instance: flowModel)

        return (
            flowModel: flowModel,
            mainTabBarViewModel: mainTabBarViewModel,
            importDictionaryArchiveUseCaseFactory: importDictionaryArchiveUseCaseFactory
        )
    }
}