//
//  DictionaryListBrowserViewModelTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 19.08.2022.
//

import XCTest
import Mockingbird

import LyraPlay

class DictionaryListBrowserViewModelTests: XCTestCase {
    
    typealias SUT = (
        viewModel: DictionaryListBrowserViewModel,
        dictionaryListBrowserDelegate: DictionaryListBrowserViewModelDelegate,
        browseDictionaryUseCase: BrowseDictionaryUseCaseMock
    )
    
    func createSUT(file: StaticString = #filePath, line: UInt = #line) -> SUT {
        
        let dictionaryListBrowserDelegate = mock(DictionaryListBrowserViewModelDelegate.self)
        let browseDictionaryUseCase = BrowseDictionaryUseCaseMock()
        
        let viewModel = DictionaryListBrowserViewModelImpl(
            delegate: dictionaryListBrowserDelegate,
            browseDictionaryUseCase: browseDictionaryUseCase
        )
        detectMemoryLeak(instance: viewModel, file: file, line: line)
        
        addTeardownBlock {
            reset(dictionaryListBrowserDelegate)
        }
        
        return (
            viewModel,
            dictionaryListBrowserDelegate,
            browseDictionaryUseCase
        )
    }
    
    // MARK: - Helpers
    
    private func observeStates(
        _ sut: SUT,
        timeout: TimeInterval = 1,
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws -> (([ExpectedState]) async -> Void) {
        
        var result = [ExpectedState]()
        let stateObserver = sut.viewModel.isLoading
            .sink { state in
                result.append(.init(sut, changeEvent: nil))
            }
        
        let changeObserver = sut.viewModel.listChanged
            .sink { change in
                result.append(.init(sut, changeEvent: change))
            }
        
        return { expectedStates in
            
            changeObserver.cancel()
            stateObserver.cancel()
            
            let sequence = self.expectSequence(expectedStates)
            
            result.forEach { sequence.fulfill(with: $0) }
            
            let sequenceStateObserver = sut.viewModel.isLoading
                .dropFirst()
                .sink { _ in
                    sequence.fulfill(with: .init(sut, changeEvent: nil))
                }
            
            let sequenceChangeObserver = sut.viewModel.listChanged
                .dropFirst()
                .sink { change in
                    sequence.fulfill(with: .init(sut, changeEvent: change))
                }
            
            
            sequence.wait(timeout: timeout, enforceOrder: true, file: file, line: line)
            sequenceStateObserver.cancel()
            sequenceChangeObserver.cancel()
        }
    }
    
    private func anyBrowseListDictionaryItem() -> BrowseListDictionaryItem {
        
        return .init(
            id: UUID(),
            originalText: UUID().uuidString,
            translatedText: UUID().uuidString
        )
    }
    
    private func givenNotEmptyList(_ sut: SUT) -> [BrowseListDictionaryItem] {
        
        let items = [
            anyBrowseListDictionaryItem(),
            anyBrowseListDictionaryItem()
        ]
        
        sut.browseDictionaryUseCase.willReturnItems = items
        return items
    }
    
    // MARK: - Test Methods
    
    func test_load__empty_list() async throws {
        
        // Given
        // Empty list
        let sut = createSUT()
        let assertStatesEqualTo = try observeStates(sut)
        
        // When
        await sut.viewModel.load()
        
        // Then
        await assertStatesEqualTo([
            .init(isLoading: true, changeEvent: nil),
            .init(isLoading: true, changeEvent: .loaded(items: [])),
            .init(isLoading: false, changeEvent: nil),
        ])
    }
    
    func test_load__not_empty_list() async throws {
        
        let sut = createSUT()

        // Given
        let items = givenNotEmptyList(sut)

        let assertStatesEqualTo = try observeStates(sut)
        
        // When
        await sut.viewModel.load()
        
        // Then
        await assertStatesEqualTo([
            .init(isLoading: true, changeEvent: nil),
            .init(isLoading: true, changeEvent: .loaded(items: items.map { $0.id })),
            .init(isLoading: false, changeEvent: nil),
        ])
    }
    
    func test_addItem() {
        
        // Given
        let sut = createSUT()
        

        // When
        sut.viewModel.addNewItem()
        
        // Then
        verify(sut.dictionaryListBrowserDelegate.runCreationFlow()).wasCalled(1)
    }
}

// MARK: - Helpers

extension DictionaryListBrowserViewModelTests {
    
    private struct ExpectedState: Equatable {
        
        var isLoading: Bool
        var changeEvent: ExpectedChange?

        init(isLoading: Bool, changeEvent: ExpectedChange?) {
            self.isLoading = isLoading
            self.changeEvent = changeEvent
        }
        
        init(_ sut: SUT, changeEvent: DictionaryListBrowserChangeEvent? = nil) {
            
            self.isLoading = sut.viewModel.isLoading.value
            self.changeEvent = .create(from: changeEvent)
        }
    }
    
    private enum ExpectedChange: Equatable {
        
        case loaded(items: [UUID])
        
        static func create(from item: DictionaryListBrowserChangeEvent?) -> Self? {
            
            guard let item = item else {
                return nil
            }
            
            switch item {
            case .loaded(let items):
                return .loaded(items: items.map { $0.id })
            }
        }
    }
}

// MARK: - Mocks

final class BrowseDictionaryUseCaseMock: BrowseDictionaryUseCase {

    var willReturnItems = [BrowseListDictionaryItem]()
    
    func listItems() async -> Result<[BrowseListDictionaryItem], BrowseDictionaryUseCaseError> {

        return .success(willReturnItems)
    }
}
