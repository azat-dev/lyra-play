//
//  ObserveSequenceTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 21.11.22.
//

import Foundation
import XCTest
import Combine

import LyraPlay

class ObserveSequenceTests: XCTestCase {
    
    typealias SUT = (
        observer: XCTestCase.ObserveSequence<Int, Int>,
        publisher: CurrentValueSubject<Int, Never>
    )
    
    func createSUT(initialValue: Int) -> SUT {
        
        let publisher = CurrentValueSubject<Int, Never>(initialValue)
        
        let observer = watch(publisher)
        detectMemoryLeak(instance: observer)
        
        return (
            observer,
            publisher
        )
    }
 
    func test_expectation__with_matcher__success() throws {
        
        let sut = createSUT(initialValue: 0)
        
        sut.publisher.send(1)
        sut.publisher.send(2)
        
        sut.observer.expect(match: [
            
            equalTo(value: 0),
            equalTo(value: 1),
            equalTo(value: 2)
        ])
    }
    
    func test_expectation__with_matcher__fail() throws {
        
        let sut = createSUT(initialValue: 0)
        
        sut.publisher.send(2)
        
        XCTExpectFailure("Expected fail") {
            
            sut.observer.expect(match: [
                
                equalTo(value: 0),
                equalTo(value: 1),
                equalTo(value: 2)
            ])
        }
    }
}

fileprivate func equalTo(value lhs: Int) -> XCTestCase.ObserveSequence<Int, Int>.Matcher<Int> {
    
    return { rhs in
        return rhs == lhs
    }
}
