//
//  LibraryFileFlowPresenterTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 09.09.22.
//

import Foundation
import XCTest
import Combine
import Mockingbird

import LyraPlay

class LibraryFileFlowPresenterTests: XCTestCase {
    
    typealias SUT = (
        presenter: LibraryFileFlowPresenter,
        flow: LibraryFileFlowModelMock,
        view: LibraryItemViewController
    )
    
    func createSUT(file: StaticString = #filePath, line: UInt = #line) -> SUT {
        
        let viewModel = mock(LibraryItemViewModel.self)
        let view = LibraryItemViewController(viewModel: viewModel)
        
        let viewFactory = mock(LibraryItemViewFactory.self)
        
        given(viewFactory.make(viewModel: any()))
            .willReturn(view)
        
        let flow = mock(LibraryFileFlowModel.self)
        
        given(flow.viewModel)
            .willReturn(viewModel)
        
        let attachSubtitlesFlow = CurrentValueSubject<AttachSubtitlesFlowModel?, Never>(nil)
        
        given(flow.attachSubtitlesFlow)
            .willReturn(attachSubtitlesFlow)
        
        let attachSubtitlesFlowPresenterFactory = mock(AttachSubtitlesFlowPresenterFactory.self)

        let presenter = LibraryFileFlowPresenterImpl(
            flowModel: flow,
            libraryItemViewFactory: viewFactory,
            attachSubtitlesFlowPresenterFactory: attachSubtitlesFlowPresenterFactory
        )
        
        detectMemoryLeak(instance: presenter)

        releaseMocks(
            flow,
            viewModel,
            viewFactory,
            attachSubtitlesFlowPresenterFactory
        )
        
        return (
            presenter,
            flow,
            view
        )
    }
    
    func test_push() async throws {
        
        DispatchQueue.main.sync {
            
            // Given
            let sut = createSUT()
            let container = UINavigationController()
            
            // When
            sut.presenter.present(at: container)
            
            // Then
            XCTAssertEqual(container.viewControllers.count, 1)
        }
    }
}
