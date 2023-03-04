//
//  UpdatePlayedTimeUseCaseTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 04.03.23.
//

import Foundation

import XCTest
import LyraPlay
import Mockingbird

class UpdatePlayedTimeUseCaseTests: XCTestCase {
    
    typealias SUT = (
        useCase: UpdatePlayedTimeUseCase,
        mediaLibraryRepository: MediaLibraryRepositoryInputMock
    )
    
    func createSUT() -> SUT {
        
        let mediaLibraryRepository = mock(MediaLibraryRepositoryInput.self)
        
        let useCase = UpdatePlayedTimeUseCaseImpl(
            mediaLibraryRepository: mediaLibraryRepository
        )
        
        detectMemoryLeak(instance: useCase)
        
        return (
            useCase,
            mediaLibraryRepository
        )
    }
    
    func test_updatePlayedTime() async throws {
        
        let sut = createSUT()

        // Given
        let mediaId = UUID()
        let playedTime: TimeInterval = 12345
        
        given(await sut.mediaLibraryRepository.updateFileProgress(id: mediaId, time: playedTime))
            .willReturn(.success(()))
        
        // When
        let result = await sut.useCase.updatePlayedTime(for: mediaId, time: playedTime)
        
        // Then
        try AssertResultSucceded(result)
        verify(await sut.mediaLibraryRepository.updateFileProgress(id: mediaId, time: playedTime))
            .wasCalled(1)
    }
}
