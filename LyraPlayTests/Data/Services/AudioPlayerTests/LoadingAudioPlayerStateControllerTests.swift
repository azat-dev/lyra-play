//
//  LoadingAudioPlayerStateControllerTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 06.04.23.
//

import Foundation
import XCTest
import Mockingbird
import LyraPlay

class LoadingAudioPlayerStateControllerTests: XCTestCase {
    
    typealias SUT = (
        controller: LoadingAudioPlayerStateController,
        fileId: String,
        fileData: Data,
        delegate: AudioPlayerStateControllerDelegateMock
    )
    
    func createSUT() -> SUT {
        
        let delegate = mock(AudioPlayerStateControllerDelegate.self)
        
        let fileId = UUID().uuidString
        let fileData = try! getTestFile()
        
        let controller = LoadingAudioPlayerStateController(
            fileId: fileId,
            data: fileData,
            delegate: delegate
        )
        
        detectMemoryLeak(instance: controller)
        
        releaseMocks(
            delegate
        )
        
        return (
            controller,
            fileId,
            fileData,
            delegate
        )
    }
    
    func test_prepare() async throws {
        
        // Given
        let sut = createSUT()
        
        let newFileId = "new_file_id"
        let newFileData = "new_file_data".data(using: .utf8)!

        given(sut.delegate.load(fileId: any(), data: any()))
            .willReturn(.success(()))
        
        // When
        let result = sut.controller.prepare(
            fileId: newFileId,
            data: newFileData
        )
        
        try AssertResultSucceded(result)
        
        // Then
        
        verify(sut.delegate.load(fileId: newFileId, data: newFileData))
            .wasCalled(1)
        
    }
    
    func test_runLoading() async throws {
        
        // Given
        let sut = createSUT()
        let fileId = sut.fileId
        let fileData = sut.fileData
        
        // When
        let result = sut.controller.runLoading()
        
        // Then
        try AssertResultSucceded(result)
        
        verify(
            sut.delegate.didLoad(
                session: any(ActiveAudioPlayerStateControllerSession.self, where: { $0.fileId == fileId && $0.systemPlayer.data == fileData })
            )
        ).wasCalled(1)
        
    }
    
    // MARK: - Helpers
    
    private func getTestFile(name: String = "test_music_with_tags") throws -> Data {
        
        let bundle = Bundle(for: type(of: self ))
        let url = bundle.url(forResource: name, withExtension: "mp3")!
        
        return try Data(contentsOf: url)
    }
}
