//
//  PlaySubtitlesUseCaseFactoryTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 08.08.2022.
//

import XCTest
import LyraPlay

class PlaySubtitlesUseCaseFactoryTests: XCTestCase {
    
    typealias SUT = (
        useCase: PlaySubtitlesUseCaseFactory,
        subtitlesIteratorFactory: SubtitlesIteratorFactory,
        scheduler: Scheduler
    )
    
    func createSUT() -> SUT {
        
        let scheduler = SchedulerImpl(timer: ActionTimerMock())
        let subtitlesIteratorFactory = SubtitlesIteratorFactoryImpl()
        
        let useCase = PlaySubtitlesUseCaseFactoryImpl(
            subtitlesIteratorFactory: subtitlesIteratorFactory,
            scheduler: scheduler
        )
        detectMemoryLeak(instance: useCase)
        
        return (
            useCase,
            subtitlesIteratorFactory,
            scheduler
        )
    }
    
    func anySubtitles() -> Subtitles {
        return .init(duration: 0, sentences: [])
    }
    
    func test_create() async throws {
        
        let sut = createSUT()
        
        let playSubtitlesUseCase = sut.useCase.create(with: anySubtitles())
        XCTAssertNotNil(playSubtitlesUseCase)
    }
}
