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
    
    func createSUT() -> SUT {
        
        let viewModel = SubtitlesPresenterViewModelImpl()
        detectMemoryLeak(instance: viewModel)
        
        return viewModel
    }
    
    func test_update_on_change__empty_subtitles() async throws {
        
        // Given
        let emptySubtitles = Subtitles(duration: 0, sentences: [])
        let sut = createSUT()
        
        let statesPromise = watch(sut.state, mapper: { ExpectedState(from: $0) })
        
        // When
        sut.update(with: .init(position: nil, subtitles: emptySubtitles))
        
        // Then
        statesPromise.expect([
            .loading,
            .playing(activeSentenceIndex: nil, rows: [])
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
        let sut = createSUT()
        
        let statesPromise = watch(sut.state, mapper: { ExpectedState(from: $0) })
        
        // When
        sut.update(with: .init(position: nil, subtitles: notEmptySubtitles))
        sut.update(with: .init(position: .sentence(0), subtitles: notEmptySubtitles))
        sut.update(with: .init(position: nil, subtitles: notEmptySubtitles))
        sut.update(with: .init(position: .sentence(1), subtitles: notEmptySubtitles))
        sut.update(with: .init(position: .sentence(2), subtitles: notEmptySubtitles))
        
        // Then
        statesPromise.expect([
            .loading,
            .playing(activeSentenceIndex: nil, rows: [false, false, false]),
            .playing(activeSentenceIndex: 0, rows: [true, false, false]),
            .playing(activeSentenceIndex: nil, rows: [false, false, false]),
            .playing(activeSentenceIndex: 1, rows: [false, true, false]),
            .playing(activeSentenceIndex: 2, rows: [false, false, true]),
        ])
    }
}


// MARK: - Helper Types

fileprivate extension SubtitlesPresenterViewModelTests {
    
    private enum ExpectedState: Equatable {
        
        case loading
        case playing(activeSentenceIndex: Int?, rows: [Bool])
        
        init(from source: SubtitlesPresentationState) {
            
            switch source {
                
            case .loading:
                self = .loading
                
            case .playing(let activeSentenceIndex, let rows):
                self = .playing(
                    activeSentenceIndex: activeSentenceIndex,
                    rows: rows.map { $0.isActive.value }
                )
            }
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
