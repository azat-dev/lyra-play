//
//  FileSharingViewModelTests.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 18.01.2023.
//

import Foundation
import XCTest
import Mockingbird
import LyraPlay

class FileSharingViewModelTests: XCTestCase {

    typealias SUT = (
        viewModel: FileSharingViewModel,
        provideFileForSharingUseCaseFactory: ProvideFileForSharingUseCaseFactory,
        provideFileForSharingUseCase: ProvideFileForSharingUseCaseMock,
        tempURLProvider: TempURLProviderMock,
        delegate: FileSharingViewModelDelegateMock
    )

    // MARK: - Methods

    func createSUT(outputFileName: String) -> SUT {

        let provideFileForSharingUseCaseFactory = mock(ProvideFileForSharingUseCaseFactory.self)
        let provideFileForSharingUseCase = mock(ProvideFileForSharingUseCase.self)

        let delegate = mock(FileSharingViewModelDelegate.self)
        
        let tempURLProvider = mock(TempURLProvider.self)

        let viewModel = FileSharingViewModelImpl(
            fileName: outputFileName,
            provideFileForSharingUseCaseFactory: provideFileForSharingUseCaseFactory,
            tempURLProvider: tempURLProvider,
            delegate: delegate
        )

        detectMemoryLeak(instance: viewModel)

        return (
            viewModel: viewModel,
            provideFileForSharingUseCaseFactory: provideFileForSharingUseCaseFactory,
            provideFileForSharingUseCase: provideFileForSharingUseCase,
            tempURLProvider: tempURLProvider,
            delegate: delegate
        )
    }
    
    func test_prepareFileURL() async throws {
        
        // Given
        let sut = createSUT(outputFileName: "test.json")
        
        let resultURL = URL(fileURLWithPath: "test")
        
        given(sut.tempURLProvider.provide(for: any()))
            .willReturn(resultURL)
        
        // When
        let receivedURL = sut.viewModel.prepareFileURL()
        
        // Then
        XCTAssertEqual(receivedURL, resultURL)
    }
    
    func test_dispose() async throws {

        // Given
        let sut = createSUT(outputFileName: "test.json")

        // When
        sut.viewModel.dispose()

        // Then
        verify(sut.delegate.fileSharingViewModelDidDispose()).wasCalled()
    }
}
