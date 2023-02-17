//
//  DictionaryListBrowserViewModelTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 19.08.2022.
//

import XCTest
import Combine
import Mockingbird

import LyraPlay

class DictionaryListBrowserViewModelTests: XCTestCase {
    
    typealias SUT = (
        viewModel: DictionaryListBrowserViewModel,
        dictionaryListBrowserDelegate: DictionaryListBrowserViewModelDelegate,
        browseDictionaryUseCase: BrowseDictionaryUseCaseMock
    )
    
    func createSUT(file: StaticString = #filePath, line: UInt = #line) async -> SUT {
        
        let dictionaryListBrowserDelegate = mock(DictionaryListBrowserViewModelDelegate.self)
        let browseDictionaryUseCase = mock(BrowseDictionaryUseCase.self)
        
        let pronounceTextUseCaseFactory = mock(PronounceTextUseCaseFactory.self)
        
        let dictionaryListBrowserItemViewModel = mock(DictionaryListBrowserItemViewModel.self)
        let dictionaryListBrowserItemViewModelFactory = mock(DictionaryListBrowserItemViewModelFactory.self)
        
        given(
            dictionaryListBrowserItemViewModelFactory.make(
                for: any(),
                isPlaying: any(),
                delegate: any()
            ))
            .willReturn(dictionaryListBrowserItemViewModel)
        
        let viewModel = DictionaryListBrowserViewModelImpl(
            delegate: dictionaryListBrowserDelegate,
            dictionaryListBrowserItemViewModelFactory: dictionaryListBrowserItemViewModelFactory,
            browseDictionaryUseCase: browseDictionaryUseCase,
            pronounceTextUseCaseFactory: pronounceTextUseCaseFactory
        )
        
        given(await browseDictionaryUseCase.listItems())
            .willReturn(.success([]))

        detectMemoryLeak(instance: viewModel, file: file, line: line)
        
        releaseMocks(
            dictionaryListBrowserDelegate,
            browseDictionaryUseCase,
            pronounceTextUseCaseFactory,
            dictionaryListBrowserItemViewModel,
            dictionaryListBrowserItemViewModelFactory
        )
        
        return (
            viewModel,
            dictionaryListBrowserDelegate,
            browseDictionaryUseCase
        )
    }
    
    // MARK: - Helpers
    
    private func anyBrowseListDictionaryItem() -> BrowseListDictionaryItem {
        
        return .init(
            id: UUID(),
            originalText: UUID().uuidString,
            translatedText: UUID().uuidString,
            language: "English"
        )
    }
    
    private func givenNotEmptyList(_ sut: SUT) async -> [BrowseListDictionaryItem] {
        
        let items = [
            anyBrowseListDictionaryItem(),
            anyBrowseListDictionaryItem()
        ]
        
        given(await sut.browseDictionaryUseCase.listItems())
            .willReturn(.success(items))
        
        return items
    }
    
    // MARK: - Test Methods
    
    func test_load__empty_list() async throws {
        
        // Given
        // Empty list
        let sut = await createSUT()
        
        let isLoadingPromise = watch(sut.viewModel.isLoading)
        let itemsPromise = watch(sut.viewModel.items)
        
        // When
        await sut.viewModel.load()
        
        // Then
        isLoadingPromise.expect([true, false])
        
        itemsPromise.expect([
            [],
            []
        ])
    }

    func test_load__not_empty_list() async throws {

        let sut = await createSUT()

        // Given
        let items = await givenNotEmptyList(sut)

        let isLoadingPromise = watch(sut.viewModel.isLoading)
        let itemsPromise = watch(sut.viewModel.items)

        // When
        await sut.viewModel.load()

        // Then
        isLoadingPromise.expect([true, false])
        
        itemsPromise.expect([
            [],
            items.map { $0.id }
        ])
    }

    func test_addItem() async {

        // Given
        let sut = await createSUT()

        // When
        sut.viewModel.addNewItem()

        // Then
        verify(sut.dictionaryListBrowserDelegate.runCreationFlow()).wasCalled(1)
    }
    
    func test_exportDictionary() async {

        // Given
        let sut = await createSUT()

        // When
        sut.viewModel.exportDictionary()

        // Then
        verify(sut.dictionaryListBrowserDelegate.runExportDictionaryFlow()).wasCalled(1)
    }
}
