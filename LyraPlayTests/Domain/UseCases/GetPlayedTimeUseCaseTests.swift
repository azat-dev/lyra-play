//
//  GetPlayedTimeUseCaseTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 04.03.23.
//

import Foundation

import XCTest
import LyraPlay
import Mockingbird

class GetPlayedTimeUseCaseTests: XCTestCase {
    
    typealias SUT = (
        useCase: GetPlayedTimeUseCase,
        mediaLibraryRepository: MediaLibraryRepositoryOutputMock
    )
    
    func createSUT() -> SUT {
        
        let tagsParser = mock(TagsParser.self)
        let mediaLibraryRepository = mock(MediaLibraryRepositoryOutput.self)
        
        let useCase = GetPlayedTimeUseCaseImpl(
            mediaLibraryRepository: mediaLibraryRepository
        )
        
        detectMemoryLeak(instance: useCase)
        
        return (
            useCase,
            mediaLibraryRepository
        )
    }
    
    func test_getPlayedTime() async throws {
        
        // Given
        let sut = createSUT()
        let mediaId = UUID()
        let expectedPlayedTime: TimeInterval = 12345
        
        given(await sut.mediaLibraryRepository.getItem(id: mediaId))
            .willReturn(.success(.file(anyFileWith(mediaId: mediaId, playedTime: expectedPlayedTime))))
        
        // When
        let result = await sut.useCase.getPlayedTime(for: mediaId)
        
        // Then
        let receivedPlayedTime = try AssertResultSucceded(result)
        XCTAssertEqual(receivedPlayedTime, expectedPlayedTime)
    }
    
    // MARK: - Helpers
    
    private func anyFileWith(mediaId: UUID, playedTime: TimeInterval) -> MediaLibraryFile {
        
        return .init(
            id: mediaId,
            parentId: nil,
            createdAt: .now,
            updatedAt: nil,
            title: "",
            subtitle: "",
            file: "",
            duration: 0,
            image: nil,
            genre: nil,
            playedTime: playedTime
        )
    }
}
