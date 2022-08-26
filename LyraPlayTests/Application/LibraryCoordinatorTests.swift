//
//  LibraryCoordinatorTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 26.08.22.
//

import Foundation
import XCTest
import LyraPlay
import Mockingbird


class LibraryCoordinatorTests: XCTestCase {
    
    typealias SUT = LibraryCoordinator
    
    func createSUT() -> SUT {
        
        let presenterViewModel = LibraryCoordinatorImpl()
        detectMemoryLeak(instance: presenterViewModel)
        
        return presenterViewModel
    }

    func test_start() {
        
        // Given
        let sut = createSUT()
        let container = mock(StackPresentationContainer.self)
        
        // When
        sut.start(at: container)

        // Then
        verify(container.setRoot(any())).wasCalled()
    }
}
