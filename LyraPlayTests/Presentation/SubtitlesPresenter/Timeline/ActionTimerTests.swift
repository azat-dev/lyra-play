//
//  ActionTimerTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 12.07.22.
//

import Foundation
import XCTest
import LyraPlay

class DefaultActionTimerTests: XCTestCase {
    
    typealias SUT = ActionTimer
    
    func createSUT() -> SUT {
        
        let timer = DefaultActionTimer()
        detectMemoryLeak(instance: timer)
        
        return timer
    }
    
    func testTrigger() async throws {
        
        let sut = createSUT()
        
        let sequence = expectSequence([true])
        let startTime = Date.now
        
        let expectedTime = 0.5
        
        sut.executeAfter(expectedTime) {
            
            let time = abs(startTime.timeIntervalSinceNow)
            XCTAssertEqual(time, expectedTime, accuracy: 0.05)
            sequence.fulfill(with: true)
        }
        
        sequence.wait(timeout: 3, enforceOrder: true)
    }
    
    
    func testCancel() async throws {

        let sut = createSUT()

        let expectation = expectation(description: "Don't execute")
        expectation.isInverted = true


        sut.executeAfter(0.2) {
            expectation.fulfill()
        }
        
        sut.cancel()

        wait(for: [expectation], timeout: 1)
    }
    
//    func testSpeed() async throws {
//
//        let speed = 1.5
//        let sut = createSUT(speed: )
//
//        let sequence = expectSequence([true])
//        let startTime = Date.now
//
//        let expectedTime = 1
//
//        sut.executeAfter(expectedTime) {
//
//            let time = startTime.timeIntervalSinceNow * speed
//            XCTAssertEqual(time, expectedTime, accuracy: 0.03)
//            sequence.fulfill(with: true)
//        }
//
//        sequence.wait(timeout: 3, enforceOrder: true)
//    }
}

