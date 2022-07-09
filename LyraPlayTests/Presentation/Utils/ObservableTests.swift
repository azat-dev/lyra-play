//
//  ObservableTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 27.06.22.
//

import Foundation
import LyraPlay
import XCTest

class ObservableTests: XCTestCase {

    func createSUT<T>(value: T) -> Observable<T> {
        
        let observable = Observable(value)
        
        detectMemoryLeak(instance: observable)
        return observable
    }
    
    func testListener() async throws {
        
        let numberOfValues = 10
        let testValues = (0..<numberOfValues).map { $0 }
        
        // Sequence1
        let sequence1 = self.expectSequence(testValues)
        let observable = createSUT(value: testValues.first!)

        sequence1.observe(observable)
        
        let numberOfValuesSequence1 = numberOfValues - 3
        
        for index in 1..<numberOfValuesSequence1 {
            
            let testValue = testValues[index]
            observable.value = testValue
        }
        
        let sequence2 = self.expectSequence(((numberOfValuesSequence1 - 1)..<numberOfValues).map { testValues[$0] })
        sequence2.observe(observable)
        
        for index in numberOfValuesSequence1..<numberOfValues {

            let testValue = testValues[index]
            observable.value = testValue
        }
        
        sequence1.wait(timeout: 3, enforceOrder: true)
        sequence2.wait(timeout: 3, enforceOrder: true)

        XCTAssertEqual(observable.value, testValues.last)
    }
    
    func testListenersDifferentQueues() {
        
        let expectationMain = expectation(description: "Main queue expectation fullfiled")
        let expectationNoQueue = expectation(description: "No queue expectation fullfiled")
        
        let observable = Observable(0)
        observable.observe(on: self, queue: .main) { value in
            
            if value == 1 {
                expectationMain.fulfill()
            }
        }
        
        observable.observe(on: self, queue: nil) { value in
            
            if value == 1 {
                expectationNoQueue.fulfill()
            }
        }
        
        observable.value = 1
        
        wait(for: [expectationMain, expectationNoQueue], timeout: 3, enforceOrder: false)
        XCTAssertEqual(observable.value, 1)
    }
}
