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

        let flowModel = ApplicationFlowModelImpl()

        detectMemoryLeak(instance: flowModel)

        return flowModel
    }
}
