//
//  AssertResult.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 28.06.22.
//

import Foundation
import XCTest

@discardableResult
func AssertResultSucceded<Success, Error>(
    _ expression: @autoclosure () -> Result<Success, Error>,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #filePath,
    line: UInt = #line
) throws -> Success {
    
    let result = expression()
    switch result {
        
    case .success(let successResult):
        return successResult
        
    case .failure(let _):
        XCTAssertNil(result, message(), file: file, line: line)
        return try result.get()
    }
}

@discardableResult
func AssertResultFailed<Success, Error>(
    _ expression: @autoclosure () -> Result<Success, Error>,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #filePath,
    line: UInt = #line
) throws -> Error {
    
    let result = expression()
    switch result {
        
    case .success(let successResult):
        XCTAssertFalse(true, message(), file: file, line: line)
        throw NSError(domain: "Expression must fail", code: 0)
        
    case .failure(let error):
        return error
    }
}
