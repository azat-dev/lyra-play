//
//  SubtitlesPresenterViewModelTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 10.07.22.
//

import Foundation
import XCTest
import Combine
import Mockingbird

import LyraPlay

class SubtitlesPresenterViewModelTests: XCTestCase {
    
    typealias SUT = SubtitlesPresenterViewModel
    
    func createSUT(subtitles: Subtitles) -> SUT {
        
        let delegate = mock(SubtitlesPresenterViewModelDelegate.self)
        
        let viewModel = SubtitlesPresenterViewModelImpl(
            subtitles: subtitles,
            timeSlots: [],
            dictionaryWords: [:],
            delegate: delegate
        )
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
        
        let positions: [SubtitlesTimeSlot?] = [
            nil,
            .init(index: 0, timeRange: 0..<1, subtitlesPosition: .sentence(0)),
            nil,
            .init(index: 1, timeRange: 1..<2, subtitlesPosition: .sentence(1)),
            .init(index: 2, timeRange: 2..<3, subtitlesPosition: .sentence(2)),
        ]
        
        // When
        positions.forEach { position in
            sut.update(position: position)
        }
        
        // Then
        statesPromise.expect(positions, timeout: 1)
    }
}
