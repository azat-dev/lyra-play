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
    
    func test_update_on_change__empty_subtitles() async throws {
        
        // Given
        let emptySubtitles = Subtitles(duration: 0, sentences: [])
        let sut = createSUT(subtitles: emptySubtitles)
        
        let statesPromise = watch(sut.state, mapper: { ExpectedState(from: $0) })
        
        // When
        sut.update(position: nil)
        
        // Then
        statesPromise.expect([
            .init(activeSentenceIndex: nil, rows: [])
        ])
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
        
        let statesPromise = watch(sut.state, mapper: { ExpectedState(from: $0) })
        
        // When
        sut.update(position: nil)
        sut.update(position: .sentence(0))
        sut.update(position: nil)
        sut.update(position: .sentence(1))
        sut.update(position: .sentence(2))
        
        // Then
        statesPromise.expect([
            .init(activeSentenceIndex: nil, rows: [false, false, false]),
            .init(activeSentenceIndex: nil, rows: [false, false, false]),
            .init(activeSentenceIndex: 0, rows: [true, false, false]),
            .init(activeSentenceIndex: nil, rows: [false, false, false]),
            .init(activeSentenceIndex: 1, rows: [false, true, false]),
            .init(activeSentenceIndex: 2, rows: [false, false, true]),
        ])
    }
}


// MARK: - Helper Types

fileprivate extension SubtitlesPresenterViewModelTests {
    
    private struct ExpectedState: Equatable {
        
        var activeSentenceIndex: Int?
        var rows: [Bool]
        
        init(activeSentenceIndex: Int? = nil, rows: [Bool]) {
            
            self.activeSentenceIndex = activeSentenceIndex
            self.rows = rows
        }
        
        init(from source: SubtitlesPresentationState) {
            
            self.activeSentenceIndex = source.activeSentenceIndex
            rows = source.rows.map { $0.isActive.value }
        }
        
        init(from sut: SUT) {
            self.init(from: sut.state.value)
        }
    }
    
    struct SentenceViewModelEquatable: Equatable {
        
        var isNil: Bool
        var isActive: Bool?
        var text: String?
        
        init(isNil: Bool, isActive: Bool?, text: String?) {
            self.isNil = false
            self.isActive = isActive
            self.text = text
        }
        
        init(from model: SentenceViewModel?) {
            
            self.isNil = (model == nil)
            self.isActive = model?.isActive.value
            self.text = model?.text
        }
    }
}
