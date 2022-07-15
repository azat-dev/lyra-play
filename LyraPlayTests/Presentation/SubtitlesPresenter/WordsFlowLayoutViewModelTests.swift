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
    
    func createSUT(
        config: WordsFlowLayoutViewModel.Config? = nil
    ) -> SUT {
        
        let itemsSizesProvider = ItemsSizesProviderMock()
        
        let viewModel = WordsFlowLayoutViewModel(
            sizesProvider: itemsSizesProvider,
            config: config
        )
        
        detectMemoryLeak(instance: viewModel)
        
        return (
            viewModel,
            itemsSizesProvider
        )
    }
    
    func testEachSectionFromNewLine() {
        
        let itemSize = CGSize(width: 1, height: 1)
        
        let testContainerSize = CGSize(width: 10, height: 10)
        let sut = createSUT()
        
        let numberOfSections = 3
        
        sut.itemsSizesProvider.sizes = (0..<numberOfSections).map { _ in [itemSize] }
        
        sut.viewModel.prepare(containerSize: testContainerSize)

        var prevOffsetY = -itemSize.height
        
        for section in 0..<numberOfSections {
            
            let (position, size, path) = sut.viewModel.getAttributes(section: section, item: 0)
            
            XCTAssertEqual(position.y, prevOffsetY + itemSize.height)
            XCTAssertEqual(size, itemSize)
            XCTAssertEqual(path, .init(item: 0, section: section))
            prevOffsetY = position.y
        }
    }
    
    func testWrapItems() {
        
        let testContainerSize = CGSize(width: 10, height: 10)
        let sut = createSUT()
        
        let sizes: [[CGSize]] = [
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
    
    func testSectionInsets() {
        
        let itemSize = CGSize(width: 1, height: 1)
        
        let sizes: [[CGSize]] = [
            [
                itemSize,
                itemSize,
            ],
            [
                itemSize,
                itemSize
            ],
        ]

        let sectionInset = UIEdgeInsets(
            top: 1.0,
            left: 3.0,
            bottom: 2.0,
            right: 4.0
        )
        
        let testContainerSize = CGSize(width: 10000, height: 10000)
        let sut = createSUT(config: .init(sectionsInsets: sectionInset))

        sut.itemsSizesProvider.sizes = sizes
        
        sut.viewModel.prepare(containerSize: testContainerSize)

        let result00 = sut.viewModel.getAttributes(section: 0, item: 0)
        let result01 = sut.viewModel.getAttributes(section: 0, item: 1)
        let result10 = sut.viewModel.getAttributes(section: 1, item: 0)
        let result11 = sut.viewModel.getAttributes(section: 1, item: 1)
        
        XCTAssertEqual(result00.position.x, sectionInset.left)
        XCTAssertEqual(result00.position.y, sectionInset.top)
        
        XCTAssertEqual(result01.position.x, sectionInset.left + result00.size.width)
        XCTAssertEqual(result01.position.y, sectionInset.top)
        
        XCTAssertEqual(result10.position.x, sectionInset.left)
        XCTAssertEqual(result10.position.y, result00.position.y + result00.size.height + sectionInset.bottom + sectionInset.top)
        
        XCTAssertEqual(result01.position.x, sectionInset.left + result00.size.width)
        XCTAssertEqual(result11.position.y, result00.position.y + result00.size.height + sectionInset.bottom + sectionInset.top)
    }
    
    func testWrapItemsWithSectionsInsets() {
        
        let testContainerSize = CGSize(width: 10, height: 10)
        let sectionsInsets = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 2)
        
        let sut = createSUT(config: .init(sectionsInsets: sectionsInsets))
        
        let halfWidth = (testContainerSize.width - sectionsInsets.left - sectionsInsets.right) / 2
        
        let sizes: [[CGSize]] = [
            [
                .init(width: halfWidth, height: 1),
                .init(width: halfWidth, height: 1),
            ],
            [
                .init(width: halfWidth, height: 1),
                .init(width: halfWidth + 1, height: 1),
            ],
        ]
        
        sut.itemsSizesProvider.sizes = sizes
        
        sut.viewModel.prepare(containerSize: testContainerSize)

        let result00 = sut.viewModel.getAttributes(section: 0, item: 0)
        let result01 = sut.viewModel.getAttributes(section: 0, item: 1)
        let result10 = sut.viewModel.getAttributes(section: 1, item: 0)
        let result11 = sut.viewModel.getAttributes(section: 1, item: 1)
        
        XCTAssertEqual(result00.position.x, sectionsInsets.left)
        XCTAssertEqual(result01.position.x, result00.position.x + result00.size.width)
        XCTAssertEqual(result00.position.y, result01.position.y)
        
        XCTAssertEqual(result10.position.x, sectionsInsets.left)
        XCTAssertEqual(result11.position.y, result10.position.y + result10.size.height + sectionsInsets.bottom + sectionsInsets.top)
        XCTAssertEqual(result11.position.x, sectionsInsets.left)
    }

    func testEmptyContentCGSize() {
        
        let testContainerSize = CGSize(width: 10000, height: 10000)
        let sut = createSUT()

        sut.itemsSizesProvider.sizes = []
        
        sut.viewModel.prepare(containerSize: testContainerSize)

        XCTAssertEqual(sut.viewModel.contentSize, .zero)
    }
    
    func testContentCGSize() {
        
        let itemSize = CGSize(width: 1, height: 1)
        
        let sizes: [[CGSize]] = [
            [
                itemSize,
                itemSize,
            ],
            [
                itemSize,
                itemSize
            ],
        ]

        let sectionInset = UIEdgeInsets(
            top: 1.0,
            left: 3.0,
            bottom: 2.0,
            right: 4.0
        )
        
        let testContainerSize = CGSize(width: 10000, height: 10000)
        let sut = createSUT(config: .init(sectionsInsets: sectionInset))

        sut.itemsSizesProvider.sizes = sizes
        
        sut.viewModel.prepare(containerSize: testContainerSize)

        let expectedContentSize = CGSize(
            width: itemSize.width * 2 + sectionInset.left + sectionInset.right,
            height: itemSize.height * 2 + (sectionInset.top + sectionInset.bottom) * 2
        )
        
        XCTAssertEqual(sut.viewModel.contentSize, expectedContentSize)
    }
    
    func testGetAttributesOfItemsInEmptyRect() {
        
//        let sut = createSUT()
//
//        let attributes = sut.viewModel.getAttributes(
//            at: .init(x: 0, y: 0),
//            withSize: .init(width: 0, height: 0)
//        )
//
//        XCTAssertTrue(attributes.isEmpty)
    }
}

// MARK: - Mocks

final class ItemsSizesProviderMock: ItemsSizesProvider {
    
    public var sizes = [[CGSize]]()
    
    var numberOfSections: Int {
        return sizes.count
    }
    
    func numberOfItems(section: Int) -> Int {
        return sizes[section].count
    }
    
    func getItemSize(section: Int, item: Int) -> CGSize {
        return sizes[section][item]
    }
}
