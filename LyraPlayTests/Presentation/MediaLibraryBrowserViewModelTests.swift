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
    
    func createSUT(folderId: UUID?, file: StaticString = #filePath, line: UInt = #line) async -> SUT {
        
        let browseUseCase = mock(BrowseMediaLibraryUseCase.self)
        
        given(await browseUseCase.fetchImage(name: any()))
            .willReturn(.success("".data(using: .utf8)!))
        
        let importFileUseCase = mock(ImportAudioFileUseCase.self)
        let delegate = mock(MediaLibraryBrowserViewModelDelegate.self)
        
        let viewModel = MediaLibraryBrowserViewModelImpl(
            folderId: folderId,
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
    
    private func anyFolder() -> MediaLibraryFolder {
        
        return .init(
            id: UUID(),
            parentId: nil,
            createdAt: .now,
            updatedAt: nil,
            title: "test",
            image: nil
        )
    }
    
    func test_load() async throws {
        
        // Given
        let folderdId = UUID()

        let sut = await createSUT(folderId: folderdId)
        
        let existingItems: [MediaLibraryItem] = [
            .folder(anyFolder()),
            .folder(anyFolder()),
        ]
        
        given(await sut.browseUseCase.listItems(folderId: folderdId))
            .willReturn(.success(existingItems))

        let itemsPromise = watch(sut.viewModel.items)
        let changedItemsPromise = watch(sut.viewModel.changedItems)

        // When
        await sut.viewModel.load()

        // Then
        let ids = existingItems.map { $0.id }

        itemsPromise.expect([
            [],
            ids
        ])

        changedItemsPromise.expect([])
    }
}
