//
//  DeleteMediaLibraryItemFlowModelTests.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 15.09.2022.
//

import Foundation
import XCTest
import Mockingbird
import LyraPlay

class DeleteMediaLibraryItemFlowModelTests: XCTestCase {

    typealias SUT = (
        flowModel: DeleteMediaLibraryItemFlowModel,
        delegate: DeleteMediaLibraryItemFlowDelegateMock,
        editMediaLibraryListUseCaseFactory: EditMediaLibraryListUseCaseFactoryMock
    )

    // MARK: - Methods

    func createSUT(itemId: UUID) -> SUT {

        let delegate = mock(DeleteMediaLibraryItemFlowDelegate.self)

        
        let editMediaLibraryListUseCase = mock(EditMediaLibraryListUseCase.self)
        let editMediaLibraryListUseCaseFactory = mock(EditMediaLibraryListUseCaseFactory.self)
        
        given(editMediaLibraryListUseCaseFactory.create())
            .willReturn(editMediaLibraryListUseCase)

        let flowModel = DeleteMediaLibraryItemFlowModelImpl(
            itemId: itemId,
            delegate: delegate,
            editMediaLibraryListUseCaseFactory: editMediaLibraryListUseCaseFactory
        )

        detectMemoryLeak(instance: flowModel)
        
        releaseMocks(
            delegate,
            editMediaLibraryListUseCaseFactory,
            editMediaLibraryListUseCase
        )

        return (
            flowModel: flowModel,
            delegate: delegate,
            editMediaLibraryListUseCaseFactory: editMediaLibraryListUseCaseFactory
        )
    }
    
    func test_start() {
        
        let mediaId = UUID()
        
        let sut = createSUT(itemId: mediaId)
    }
}
