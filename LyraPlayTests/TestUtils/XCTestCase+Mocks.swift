//
//  MockingBird+Utils.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 08.09.22.
//

import Foundation
import Mockingbird
import XCTest

extension XCTestCase {
    
    public func releaseMocks(_ mocks: Mock...) {
        
        addTeardownBlock {
            for mock in mocks {
                reset(mock)
            }
        }
    }
}
