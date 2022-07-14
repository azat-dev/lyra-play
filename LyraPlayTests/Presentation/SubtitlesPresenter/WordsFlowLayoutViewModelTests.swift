//
//  WordsFlowLayoutViewModelTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 14.07.22.
//

import Foundation
import XCTest
import LyraPlay

class WordsFlowLayoutViewModelTests: XCTestCase {
    
    typealias SUT = (
        viewModel: WordsFlowLayoutViewModel,
        itemsSizesProvider: ItemsSizesProviderMock
    )
    
    func createSUT(interItemSpace: Double, spaceBetweenLines: Double) -> SUT {
        
        let itemsSizesProvider = ItemsSizesProviderMock()
        
        let viewModel = WordsFlowLayoutViewModel(
            sizesProvider: itemsSizesProvider,
            interItemSpace: interItemSpace,
            spaceBetweenLines: spaceBetweenLines
        )
        
        detectMemoryLeak(instance: viewModel)
        
        return (
            viewModel,
            itemsSizesProvider
        )
    }
    
    func testEachSectionFromNewLine() {
        
        let itemSize = Size(width: 1, height: 1)
        
        let testContainerSize = Size(width: 10, height: 10)
        let sut = createSUT(
            interItemSpace: 0,
            spaceBetweenLines: 0
        )
        
        let numberOfSections = 3
        
        sut.itemsSizesProvider.sizes = (0..<numberOfSections).map { _ in [itemSize] }
        
        sut.viewModel.prepare(containerSize: testContainerSize)

        var prevOffsetY = -itemSize.height
        
        for section in 0..<numberOfSections {
            
            let (position, size, path) = sut.viewModel.getAttributes(section: section, item: 0)
            
            XCTAssertEqual(position.y, prevOffsetY + itemSize.height)
            XCTAssertEqual(size, itemSize)
            XCTAssertEqual(path, .init(section: section, item: 0))
            prevOffsetY = position.y
        }
    }
    
    func testWrapItems() {
        
        let testContainerSize = Size(width: 10, height: 10)
        let sut = createSUT(
            interItemSpace: 0,
            spaceBetweenLines: 0
        )
        
        let sizes: [[Size]] = [
            [
                .init(width: testContainerSize.width / 2, height: 1),
                .init(width: testContainerSize.width / 2, height: 1),
            ],
            [
                .init(width: testContainerSize.width / 2, height: 1),
                .init(width: testContainerSize.width / 2 + 1, height: 1),
            ],
        ]
        
        sut.itemsSizesProvider.sizes = sizes
        
        sut.viewModel.prepare(containerSize: testContainerSize)

        let result00 = sut.viewModel.getAttributes(section: 0, item: 0)
        let result01 = sut.viewModel.getAttributes(section: 0, item: 1)
        let result10 = sut.viewModel.getAttributes(section: 1, item: 0)
        let result11 = sut.viewModel.getAttributes(section: 1, item: 1)
        
        XCTAssertEqual(result00.position.x, 0)
        XCTAssertEqual(result01.position.x, result00.position.x + result00.size.width)
        XCTAssertEqual(result00.position.y, result01.position.y)
        
        XCTAssertEqual(result10.position.x, 0.0)
        XCTAssertEqual(result11.position.y, result10.position.y + result10.size.height)
        XCTAssertEqual(result11.position.x, 0.0)
    }
}

// MARK: - Mocks

final class ItemsSizesProviderMock: ItemsSizesProvider {
    
    public var sizes = [[Size]]()
    
    var numberOfSections: Int {
        return sizes.count
    }
    
    func numberOfItems(section: Int) -> Int {
        return sizes[section].count
    }
    
    func getItemSize(section: Int, item: Int) -> Size {
        return sizes[section][item]
    }
}
