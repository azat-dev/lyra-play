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
    
    let receivedValueDumped = dumpValue(receivedValue)
    let expectedValueDumped = dumpValue(expectedValue)
    
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
    
    if receivedValueDumped == expectedValueDumped {
        return
    }
    
    logChanges(
        receivedValueDumped: receivedValueDumped,
        expectedValueDumped: expectedValueDumped,
        file: file,
        line: line
    )
}

func dumpValue<T>(_ value: T) -> String {
    
    var dumped = String()
    dump(value, to: &dumped)
    
    return dumped
}

func logChanges(receivedValueDumped: String, expectedValueDumped: String, file: StaticString = #filePath, line: UInt = #line) {

    let semaphore = DispatchSemaphore(value: 0)
    
    Task(priority: .medium) {
        
        defer { semaphore.signal() }

        var request = URLRequest(url: .init(string: "http://localhost:8080/logs/dump")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let data: [String: String] = [
            "method": "AssertEqualReadable",
            "receivedValue": receivedValueDumped,
            "expectedValue": expectedValueDumped,
            "file": String(describing: file),
            "line": String(line)
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: data)
        
        await withCheckedContinuation({ continiuation in
            
            URLSession.shared.dataTask(with: request) { _, _, _ in
                
                continiuation.resume()
            }.resume()
        })
    }
    
    semaphore.wait()
}
