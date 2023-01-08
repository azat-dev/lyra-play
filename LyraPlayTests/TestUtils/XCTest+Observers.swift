//
//  XCTest+Observers.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 16.09.22.
//

import Foundation
import XCTest
import Combine
import LyraPlay

extension XCTestCase {
    
    func watch<P, MappedValue>(
        _ publisher: P,
        mapper: @escaping (P.Output) -> MappedValue
    ) -> ObserveSequence<P.Output, MappedValue>
    
    where P: Publisher, MappedValue: Equatable, P.Failure == Never  {
        
        let sequence = ObserveSequence<P.Output, MappedValue>(testCase: self, mapper: mapper)
        
        let observer = publisher.sink { value in
            
            sequence.fulfill(with: value)
        }
        
        sequence.onTearDown = {
            observer.cancel()
        }
        
        return sequence
    }
    
    func watch<P>(_ publisher: P) -> ObserveSequence<P.Output, P.Output>
        where P: Publisher, P.Failure == Never  {
        
        let sequence = ObserveSequence<P.Output, P.Output>(testCase: self)
        
        let observer = publisher.sink { value in
            sequence.fulfill(with: value)
        }
        
        sequence.onTearDown = {
            observer.cancel()
        }
        
        return sequence
    }
    
    func watch<Value, MappedValue>(
        _ publisher: Observable<Value>,
        mapper: @escaping (Value) -> MappedValue
    ) -> ObserveSequence<Value, MappedValue> where MappedValue: Equatable  {
        
        let sequence = ObserveSequence<Value, MappedValue>(testCase: self, mapper: mapper)
        
        let token = ObserverToken()
        
        publisher.observe(on: token) { value in
            sequence.fulfill(with: value)
        }
        
        sequence.onTearDown = {
            publisher.remove(observer: token)
        }
        
        return sequence
    }
    
    func watch<Value>(
        _ publisher: Observable<Value>
    ) -> ObserveSequence<Value, Value> where Value: Equatable  {
        
        let sequence = ObserveSequence<Value, Value>(testCase: self)
        
        let token = ObserverToken()
        
        publisher.observe(on: token) { value in
            sequence.fulfill(with: value)
        }
        
        sequence.onTearDown = {
            publisher.remove(observer: token)
        }
        
        return sequence
    }
}

public protocol ValueMatcher {
    
    associatedtype CapturedValue    
    
    func match(capturedValue: CapturedValue) -> Bool
}

extension XCTestCase {
    
    public class ObserveSequence<Value, MappedValue> {

        // MARK: - Properties
        
        private unowned var testCase: XCTestCase
        
        private let semaphore = DispatchSemaphore(value: 1)
        private weak var expectation: XCTestExpectation?
        
        public var capturedValues = [Value]()
        public var capturedMappedValues = [MappedValue]()
        
        private let mapper: (_: Value) -> MappedValue
        
        public var onTearDown: (() -> Void)?
        
        // MARK: - Initializers
        
        public required init(testCase: XCTestCase, mapper: @escaping (_: Value) -> MappedValue) {
            
            self.testCase = testCase
            self.mapper = mapper
        }
        
        public convenience init(testCase: XCTestCase) where Value == MappedValue {
            
            self.init(testCase: testCase, mapper: { $0 })
        }
        
        // MARK: - Methods
        
        func fulfill(with value: Value) {

            defer { semaphore.signal() }
            semaphore.wait()
            
            capturedValues.append(value)
            capturedMappedValues.append(mapper(value))
            
            expectation?.fulfill()
        }
        
        func expect(
            _ expectedValues: [MappedValue],
            timeout: TimeInterval = 1,
            file: StaticString = #filePath,
            line: UInt = #line
        ) where MappedValue: Equatable {
            
            if capturedValues.count < expectedValues.count {
                
                semaphore.wait()
                
                let valuesExpectation = testCase.expectation(description: "Wait for rest items")
                valuesExpectation.expectedFulfillmentCount = expectedValues.count
                
                capturedValues.forEach { _ in
                    valuesExpectation.fulfill()
                }
                
                self.expectation = valuesExpectation
                semaphore.signal()

                testCase.wait(for: [valuesExpectation], timeout: timeout)
            }
            
            
            if let onTearDown = onTearDown {
                onTearDown()
            }
            
            AssertEqualReadable(
                capturedMappedValues,
                expectedValues,
                file: file,
                line: line
            )
        }
        
        func expect<Matcher: ValueMatcher>(
            match matchers: [Matcher],
            timeout: TimeInterval = 1,
            file: StaticString = #filePath,
            line: UInt = #line
        ) where Value == Matcher.CapturedValue  {
            
            if capturedValues.count < matchers.count {
                
                semaphore.wait()
                
                let valuesExpectation = testCase.expectation(description: "Wait for rest items")
                valuesExpectation.expectedFulfillmentCount = matchers.count
                
                capturedValues.forEach { _ in
                    valuesExpectation.fulfill()
                }
                
                self.expectation = valuesExpectation
                semaphore.signal()

                testCase.wait(for: [valuesExpectation], timeout: timeout)
            }
            
            if let onTearDown = onTearDown {
                onTearDown()
            }
            
            for index in 0..<matchers.count {
                
                let matcher = matchers[index]
                let capturedValue = capturedValues[index]
                
                guard matcher.match(capturedValue: capturedValue) else {
                    XCTFail("Captured value at index \(index) doesn't match: \(capturedValue)", file: file, line: line)
                    return
                }
            }
        }
    }
}
