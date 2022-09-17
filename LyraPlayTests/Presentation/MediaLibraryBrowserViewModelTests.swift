//
//  MediaLibraryBrowserViewModelTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 27.06.22.
//

import Foundation
import Combine
import XCTest
import Mockingbird

import LyraPlay

class MediaLibraryBrowserViewModelTests: XCTestCase {
    
    typealias SUT = (
        viewModel: MediaLibraryBrowserViewModel,
        browseUseCase: BrowseMediaLibraryUseCaseMock
    )
    
    func createSUT(file: StaticString = #filePath, line: UInt = #line) async -> SUT {
        
        let browseUseCase = mock(BrowseMediaLibraryUseCase.self)
        
        given(await browseUseCase.fetchImage(name: any()))
            .willReturn(.success("".data(using: .utf8)!))
        
        let importFileUseCase = mock(ImportAudioFileUseCase.self)
        let delegate = mock(MediaLibraryBrowserViewModelDelegate.self)
        
        let viewModel = MediaLibraryBrowserViewModelImpl(
            delegate: delegate,
            browseUseCase: browseUseCase,
            importFileUseCase: importFileUseCase
        )
        
        detectMemoryLeak(instance: viewModel, file: file, line: line)
        
        releaseMocks(
            delegate,
            importFileUseCase,
            browseUseCase
        )
        
        return (
            viewModel,
            browseUseCase
        )
    }
    
    private func getTestFile(index: Int) -> (info: AudioFileInfo, data: Data) {
        return (
            info: AudioFileInfo.create(name: "Test \(index)", duration: 19, audioFile: "test.mp3"),
            data: "Test \(index)".data(using: .utf8)!
        )
    }
    
    func test_load() async throws {
        
        let sut = await createSUT()
        
        // Given
        let testFiles: [AudioFileInfo] = (0...3).map { _ in .anyExistingItem() }

        given(await sut.browseUseCase.listFiles())
            .willReturn(.success(testFiles))
        
        let itemsPromise = watch(sut.viewModel.items)
        let changedItemsPromise = watch(sut.viewModel.changedItems)

        // When
        await sut.viewModel.load()

        // Then
        let ids = testFiles.map { $0.id! }

        itemsPromise.expect([
            [],
            ids
        ])

        changedItemsPromise.expect([])
    }
}
