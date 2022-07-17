//
//  ActionTimerFactoryTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 12.07.22.
//

import Foundation
import XCTest
import LyraPlay

class ActionTimerFactoryTests: XCTestCase {
    
    typealias SUT = ActionTimerFactory
    
    func createSUT() -> SUT {
        
        let factory = DefaultActionTimerFactory()
        detectMemoryLeak(instance: factory)
        
        return factory
    }

    func testCreate() async throws {
        
        let sut = createSUT()
        
        XCTAssertNotNil(sut.create())
    }
}

