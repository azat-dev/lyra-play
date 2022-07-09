//
//  XCTestCase+Sequence.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 09.07.22.
//

import Foundation
import XCTest

extension XCTestCase {
    
    func expectSequence<T: Equatable>(_ values: [T]) -> AssertSequence<T> {
        return AssertSequence(testCase: self, values: values)
    }
}
