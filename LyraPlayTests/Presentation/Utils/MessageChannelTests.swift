//
//  MessageChannelTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 06.07.22.
//

import Foundation
import LyraPlay
import XCTest

class MessageChannelTests: XCTestCase {

    func createSUT<T>() -> MessageChannel<T> {
        
        let channel = MessageChannel<T>()
        
        detectMemoryLeak(instance: channel)
        return channel
    }
    
    func testListener() async throws {
        
        let numberOfValues = 10
        let testValues = (0..<numberOfValues).map { $0 }
        
        // Sequence1
        let sequence1 = self.expectSequence(testValues)
        let channel: MessageChannel<Int> = createSUT()

        sequence1.observe(channel)
        
        let numberOfValuesSequence1 = numberOfValues - 3
        
        for index in 0..<numberOfValuesSequence1 {
            
            let testValue = testValues[index]
            channel.send(testValue)
        }
        
        let sequence2 = self.expectSequence((numberOfValuesSequence1..<numberOfValues).map { testValues[$0] })
        sequence2.observe(channel)
        
        for index in numberOfValuesSequence1..<numberOfValues {

            let testValue = testValues[index]
            channel.send(testValue)
        }
        
        sequence1.wait(timeout: 3, enforceOrder: true)
        sequence2.wait(timeout: 3, enforceOrder: true)
    }
    
    func testListenersDifferentQueues() {
        
        let expectationMain = expectation(description: "Main queue expectation fullfiled")
        let expectationNoQueue = expectation(description: "No queue expectation fullfiled")
        
        let channel: MessageChannel<Int> = createSUT()
        channel.observe(on: self, queue: .main) { value in
            
            if value == 1 {
                expectationMain.fulfill()
            }
        }
        
        channel.observe(on: self, queue: nil) { value in
            
            if value == 1 {
                expectationNoQueue.fulfill()
            }
        }
        
        channel.send(1)
        
        wait(for: [expectationMain, expectationNoQueue], timeout: 3, enforceOrder: false)
    }
}
