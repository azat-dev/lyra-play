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

    func testListener() async throws {
        
        let numberOfValues = 10
        let testValues = (0..<numberOfValues).map { $0 }
        
        // Sequence1
        let valuesExpectationsListener1 = testValues.indices.map { expectation(description: "Listener1: value expectation: index = \($0)")}
        let observable = Observable(testValues.first!)
        
        observable.observe(on: self) { newValue in
            
            guard let expectationIndex = testValues.firstIndex(of: newValue) else {
                XCTAssertFalse(true, "Unexpected value: \(newValue)")
                return
            }

            let expectation = valuesExpectationsListener1[expectationIndex]
            expectation.fulfill()
        }
        
        let numberOfValuesSequence1 = numberOfValues - 3
        
        for index in 1..<numberOfValuesSequence1 {
            
            let testValue = testValues[index]
            observable.value = testValue
        }

        // Sequence2
        
        let valuesExpectationsListener2 = (0..<numberOfValues).map { index -> XCTestExpectation in

            guard index >= numberOfValuesSequence1 - 1 else {
                
                let invertedExpectation = expectation(description: "Listner2: value expectation - index = \(index)")
                invertedExpectation.isInverted = true
                return invertedExpectation
            }

            return expectation(description: "Listner2 value expectation: index = \(index)")
        }


        observable.observe(on: self) { newValue in

            guard let expectationIndex = testValues.firstIndex(of: newValue) else {
                XCTAssertFalse(true, "Unexpected value: \(newValue)")
                return
            }

            let expectation = valuesExpectationsListener2[expectationIndex]
            expectation.fulfill()
        }


        for index in numberOfValuesSequence1..<numberOfValues {

            let testValue = testValues[index]
            observable.value = testValue
        }

        // Wait for results
        
        wait(
            for: valuesExpectationsListener1,
            timeout: 2,
            enforceOrder: true
        )

        wait(
            for: valuesExpectationsListener2,
            timeout: 2,
            enforceOrder: true
        )
    }
}
