//
//  ActionTimer.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 12.07.22.
//

import Foundation
import XCTest
import LyraPlay

class DefaultActionTimerTests: XCTestCase {
    
    typealias SUT = ActionTimer
    
    func createSUT(speed: Double) -> SUT {
        
        let timer = DefaultActionTimer(speed: speed)
        detectMemoryLeak(instance: timer)
        
        return timer
    }
    
    func testTrigger() async throws {
        
        let sut = createSUT(speed: 1.0)
        
        let sequence = expectSequence([true])
        let startTime = Date.now
        
        let expectedTime = 0.5
        
        sut.executeAfter(expectedTime) {
            
            let time = startTime.timeIntervalSinceNow
            XCTAssertEqual(time, expectedTime, accuracy: 0.03)
            sequence.fulfill(with: true)
        }
        
        sequence.wait(timeout: 3, enforceOrder: true)
    }
    
    func testCancel() async throws {
        
        let sut = createSUT(speed: 1.0)
        
        let expectation = expectation(description: "")
        expectation.isInverted = true
        
        let expectedTime = 0.2
        
        sut.executeAfter(0.2) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2)
    }
    
    func testSpeed() async throws {
        
        let speed = 1.5
        let sut = createSUT(speed: )
        
        let sequence = expectSequence([true])
        let startTime = Date.now
        
        let expectedTime = 1
        
        sut.executeAfter(expectedTime) {
            
            let time = startTime.timeIntervalSinceNow * speed
            XCTAssertEqual(time, expectedTime, accuracy: 0.03)
            sequence.fulfill(with: true)
        }
        
        sequence.wait(timeout: 3, enforceOrder: true)
    }
}

