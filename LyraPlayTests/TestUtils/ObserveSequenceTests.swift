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
    
    fileprivate typealias SUT = (
        observer: XCTestCase.ObserveSequence<NotEquatable, NotEquatable>,
        publisher: CurrentValueSubject<NotEquatable, Never>
    )
    
    fileprivate func createSUT(initialValue: NotEquatable) -> SUT {
        
        let publisher = CurrentValueSubject<NotEquatable, Never>(initialValue)
        
        let observer = watch(publisher)
        detectMemoryLeak(instance: observer)
        
        return (
            observer,
            publisher
        )
    }
 
    func test_expectation__with_matcher__success() throws {
        
        let sut = createSUT(initialValue: NotEquatable(value: 0))
        
        sut.publisher.send(NotEquatable(value: 1))
        sut.publisher.send(NotEquatable(value: 2))
        
        sut.observer.expect(match: [
            
            MatchNotEquatable(0),
            MatchNotEquatable(1),
            MatchNotEquatable(2)
        ])
    }
    
    func test_expectation__with_matcher__fail() throws {
        
        let sut = createSUT(initialValue: NotEquatable(value: 0))
        
        sut.publisher.send(NotEquatable(value: 2))
        
        XCTExpectFailure("Expected fail") {
            
            sut.observer.expect(match: [
                
                MatchNotEquatable(0),
                MatchNotEquatable(1),
                MatchNotEquatable(2)
            ])
        }
    }
}

// MARK: - Helpers
    
struct NotEquatable {
    
    let value: Int
}

struct MatchNotEquatable: ValueMatcher {
    
    typealias ExpectedValue = Int
    
    typealias CapturedValue = NotEquatable
    
    // MARK: - Properties
    
    var expectedValue: ExpectedValue
    
    // MARK: - Initializers
    
    init(_ expectedValue: ExpectedValue) {
        
        self.expectedValue = expectedValue
    }
    
    // MARK: - Methods
    
    func match(capturedValue: NotEquatable) -> Bool {
        
        return capturedValue.value == expectedValue
    }
}
