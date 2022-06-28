//
//  AssertResult.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 28.06.22.
//

import Foundation

@discardableResult
func AssertResultSucceded<Success, Error>(
    _ expression: @autoclosure () -> Result<Success, Error>,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #filePath,
    line: UInt = #line
) -> Success {
    
    let result = expression()
    switch result {
        
    case .success(let successResult):
        return successResult
        
    case .failure(let error):
        XCTAssertNil(error, message(), file: file, line: line)
    }
    
    fatalError()
}

@discardableResult
func AssertResultFailed<Success, Error>(
    _ expression: @autoclosure () -> Result<Success, Error>,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #filePath,
    line: UInt = #line
) -> Error {
    
    let result = expression()
    switch result {
        
    case .success(let successResult):
        XCTAssertFalse(true, message(), file: file, line: line)
        
    case .failure(let error):
        return error
    }
    
    fatalError()
}
