//
//  XCTestCase+MemoryLeakDetection.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 06.07.22.
//

import Foundation
import XCTest

extension XCTestCase {
    
    func detectMemoryLeak(instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        
        addTeardownBlock { [weak instance] in
            print("Detct")
            XCTAssertNil(
                instance,
                "Memory leak: the instance must have been deallocated",
                file: file,
                line: line
            )
        }
    }
}
