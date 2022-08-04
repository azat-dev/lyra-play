//
//  AssertEqualReadable.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 01.08.22.
//

import Foundation
import XCTest

public func AssertEqualReadable<T>(
    _ expression1: @autoclosure () throws -> T,
    _ expression2: @autoclosure () throws -> T,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #filePath,
    line: UInt = #line
) where T : Equatable {
    
    let receivedValue = try! expression1()
    let expectedValue = try! expression2()
    
    var receivedValueDumped = String()
    dump(receivedValue, to: &receivedValueDumped)
    
    var expectedValueDumped = String()
    dump(expectedValue, to: &expectedValueDumped)
    
    var errorText = message()
    
    if !errorText.isEmpty {
        errorText = "\n\n"
    }
    
    errorText += "\n\nReceived: \(receivedValueDumped)"
    errorText += "\n\nExpected: \(expectedValueDumped)"
    
    XCTAssertEqual(
        receivedValue,
        expectedValue,
        errorText,
        file: file,
        line: line
    )
}
