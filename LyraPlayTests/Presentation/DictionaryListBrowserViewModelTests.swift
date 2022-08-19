//
//  DictionaryListBrowserViewModelTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 19.08.2022.
//

import XCTest
import LyraPlay

class DictionaryListBrowserViewModelTests: XCTestCase {
    
    typealias SUT = (
        viewModel: DictionaryListBrowserViewModel,
        dictionaryListBrowserCoordinator: DictionaryListBrowserCoordinatorMock,
        browseDictionaryUseCase: BrowseDictionaryUseCaseMock
    )
    
    func createSUT() -> SUT {
        
        let dictionaryListBrowserCoordinator = DictionaryListBrowserCoordinatorMock()
        let browseDictionaryUseCase = BrowseDictionaryUseCaseMock()
        
        let viewModel = DefaultDictionaryListBrowserViewModel(
            dictionaryListBrowserCoordinator: dictionaryListBrowserCoordinator,
            browseDictionaryUseCase: browseDictionaryUseCase
        )
        detectMemoryLeak(instance: viewModel)
        
        return (
            viewModel,
            dictionaryListBrowserCoordinator,
            browseDictionaryUseCase
        )
    }
    
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
    
    func test_load__emptyList() async throws {
        
        // Given
        // Empty list
        let sut = createSUT()
        
        let assertStatesEqualTo = try observeStates(sut)
        
        // When
        sut.viewModel.load()
        
        // Then
        await assertStatesEqualTo([
            .init(isLoading: true, changeEvent: nil),
            .init(isLoading: true, changeEvent: .loaded(items: [])),
            .init(isLoading: false, changeEvent: nil),
        ])
    }
}

// MARK: - Helpers

extension DictionaryListBrowserViewModelTests {
    
    private struct ExpectedState: Equatable {
        
        var isLoading: Bool
        var changeEvent: DictionaryListBrowserChangeEvent?

        init(isLoading: Bool, changeEvent: DictionaryListBrowserChangeEvent?) {
            self.isLoading = isLoading
            self.changeEvent = changeEvent
        }
        
        init(_ sut: SUT, changeEvent: DictionaryListBrowserChangeEvent? = nil) {
            
            self.isLoading = sut.viewModel.isLoading.value
            self.changeEvent = changeEvent
        }
    }
}

// MARK: - Mocks

final class DictionaryListBrowserCoordinatorMock: DictionaryListBrowserCoordinator {
    
}

// MARK: - Mocks

final class BrowseDictionaryUseCaseMock: BrowseDictionaryUseCase {

    var willReturnItems = [BrowseListDictionaryItem]()
    
    func listItems() async -> Result<[BrowseListDictionaryItem], BrowseDictionaryUseCaseError> {

        return .success(willReturnItems)
    }
}
