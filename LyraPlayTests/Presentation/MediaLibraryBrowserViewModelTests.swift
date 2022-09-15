//
//  MediaLibraryBrowserViewModelTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 27.06.22.
//

import Foundation
import XCTest
import Mockingbird

import LyraPlay

class MediaLibraryBrowserViewModelTests: XCTestCase {
    
    typealias SUT = (
        viewModel: MediaLibraryBrowserViewModel,
        browseUseCase: BrowseMediaLibraryUseCaseMock,
        filesDelegate: MediaLibraryBrowserUpdateDelegateMock
    )
    
    func createSUT(file: StaticString = #filePath, line: UInt = #line) -> SUT {
        
        let browseUseCase = mock(BrowseMediaLibraryUseCase.self)
        
        let filesDelegate = mock(MediaLibraryBrowserUpdateDelegate.self)
        let importFileUseCase = mock(ImportAudioFileUseCase.self)
        let delegate = mock(MediaLibraryBrowserViewModelDelegate.self)
        
        let viewModel = MediaLibraryBrowserViewModelImpl(
            delegate: delegate,
            browseUseCase: browseUseCase,
            importFileUseCase: importFileUseCase
        )
        viewModel.filesDelegate = filesDelegate
        
        detectMemoryLeak(instance: viewModel, file: file, line: line)
        
        releaseMocks(
            filesDelegate,
            delegate,
            importFileUseCase
        )
        
        return (
            viewModel,
            browseUseCase,
            filesDelegate
        )
    }
    
    private func getTestFile(index: Int) -> (info: AudioFileInfo, data: Data) {
        return (
            info: AudioFileInfo.create(name: "Test \(index)", duration: 19, audioFile: "test.mp3"),
            data: "Test \(index)".data(using: .utf8)!
        )
    }
    
    func test_load() async throws {
        
        let sut = createSUT()
        
        let testFiles: [AudioFileInfo] = (0...3).map { _ in .anyExistingItem() }
        
        // Given
        given(await sut.browseUseCase.listFiles())
            .willReturn(.success(testFiles))

        // When
        await sut.viewModel.load()

        // Then
        eventually {
            verify(sut.filesDelegate.filesDidUpdate(updatedFiles: testFiles.map { $0.id! }))
                .wasCalled(1)
        }

        await waitForExpectations(timeout: 1)
    }
}
