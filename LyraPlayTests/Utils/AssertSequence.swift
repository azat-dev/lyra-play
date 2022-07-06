//
//  AssertSequence.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 05.07.22.
//

import Foundation
import XCTest
import LyraPlay

class AssertSequence<T: Equatable> {
    
    private unowned var testCase: XCTestCase
    private var expectedValues: [T] = [] {
        didSet {
            expectation.expectedFulfillmentCount = expectedValues.count
        }
    }
    
    private var receivedValues = [T]()
    private var expectation = XCTestExpectation()
    
    
    init(testCase: XCTestCase, values: [T] = []) {
        
        self.testCase = testCase
        
        addExpectations(values: values)
    }
    
    func addExpectation(value: T) {

        expectedValues.append(value)
    }
    
    func addExpectations(values: [T]) {
        
        values.forEach { value in
            addExpectation(value: value)
        }
    }
    
    func wait(timeout: TimeInterval, enforceOrder: Bool, file: StaticString = #filePath, line: UInt = #line) {
        
        if !enforceOrder {
            fatalError("Not implemented")
        }
        
        testCase.wait(for: [expectation], timeout: timeout, enforceOrder: enforceOrder)
        XCTAssertEqual(receivedValues, expectedValues, file: file, line: line)
    }
}

// MARK: - Observable

extension AssertSequence {
    
    func observe(_ observable: Observable<T>, file: StaticString = #filePath, line: UInt = #line) {
        
        observe(observable, mapper: { $0 }, file: file, line: line)
    }
    
    func observe<X>(_ observable: Observable<X>, mapper: @escaping (X) -> T, file: StaticString = #filePath, line: UInt = #line) {
        
        observable.observe(on: self) { [weak self] value in
            
            guard let self = self else {
                return
            }
            
            let mappedValue = mapper(value)
            
            self.receivedValues.append(mappedValue)
            self.expectation.fulfill()
        }
    }
}

// MARK: - MessageChannel

extension AssertSequence {
    
    func observe(_ channel: MessageChannel<T>, file: StaticString = #filePath, line: UInt = #line) {
        
        observe(channel, mapper: { $0 }, file: file, line: line)
    }
    
    
    func observe<X>(_ channel: MessageChannel<X>, mapper: @escaping (X) -> T, file: StaticString = #filePath, line: UInt = #line) {
        
        channel.observe(on: self) { [weak self] value in
            
            guard let self = self else {
                return
            }
            
            let mappedValue = mapper(value)
            
            self.receivedValues.append(mappedValue)
            self.expectation.fulfill()
        }
    }
}
