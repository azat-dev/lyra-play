//
//  SubtitlesPresenterViewModelTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 10.07.22.
//

import Foundation
import XCTest
import Combine

import LyraPlay

class SubtitlesPresenterViewModelTests: XCTestCase {
    
    typealias SUT = SubtitlesPresenterViewModel
    
    func createSUT(subtitles: Subtitles) -> SUT {
        
        let viewModel = SubtitlesPresenterViewModelImpl(subtitles: subtitles)
        detectMemoryLeak(instance: viewModel)
        
        return viewModel
    }
    
    func test_update_on_change__not_empty_subtitles() async throws {
        
        // Given
        let notEmptySubtitles = Subtitles(
            duration: 10,
            sentences: [
                .anySentence(at: 0),
                .anySentence(at: 1),
                .anySentence(at: 2),
            ]
        )
        let sut = createSUT(subtitles: notEmptySubtitles)
        
        let statesPromise = watch(sut.position)
        
        let positions: [SubtitlesPosition?] = [
            nil,
            .sentence(0),
            nil,
            .sentence(1),
            .sentence(2)
        ]
        // When
        
        positions.forEach { position in
            sut.update(position: position)
        }
        
        // Then
        
        statesPromise.expect(positions, timeout: 1)
    }
}
