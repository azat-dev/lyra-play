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
            
            let (frame, path) = sut.viewModel.getAttributes(section: section, item: 0)
            
            XCTAssertEqual(frame.minY, prevOffsetY + itemSize.height)
            XCTAssertEqual(frame.size, itemSize)
            XCTAssertEqual(path, .init(item: 0, section: section))
            prevOffsetY = frame.minY
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
        
        XCTAssertEqual(result00.frame.origin.x, 0)
        XCTAssertEqual(result01.frame.origin.x, result00.frame.origin.x + result00.frame.size.width)
        XCTAssertEqual(result00.frame.origin.y, result01.frame.origin.y)
        
        XCTAssertEqual(result10.frame.origin.x, 0.0)
        XCTAssertEqual(result11.frame.origin.y, result10.frame.origin.y + result10.frame.size.height)
        XCTAssertEqual(result11.frame.origin.x, 0.0)
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
        
        XCTAssertEqual(result00.frame.origin.x, sectionInset.left)
        XCTAssertEqual(result00.frame.origin.y, sectionInset.top)
        
        XCTAssertEqual(result01.frame.origin.x, sectionInset.left + result00.frame.size.width)
        XCTAssertEqual(result01.frame.origin.y, sectionInset.top)
        
        XCTAssertEqual(result10.frame.origin.x, sectionInset.left)
        XCTAssertEqual(result10.frame.origin.y, result00.frame.origin.y + result00.frame.size.height + sectionInset.bottom + sectionInset.top)
        
        XCTAssertEqual(result01.frame.origin.x, sectionInset.left + result00.frame.size.width)
        XCTAssertEqual(result11.frame.origin.y, result00.frame.origin.y + result00.frame.size.height + sectionInset.bottom + sectionInset.top)
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
        
        XCTAssertEqual(result00.frame.origin.x, sectionsInsets.left)
        XCTAssertEqual(result01.frame.origin.x, result00.frame.origin.x + result00.frame.size.width)
        XCTAssertEqual(result00.frame.origin.y, result01.frame.origin.y)
        
        XCTAssertEqual(result10.frame.origin.x, sectionsInsets.left)
        XCTAssertEqual(result11.frame.origin.y, result10.frame.origin.y + result10.frame.size.height + sectionsInsets.bottom + sectionsInsets.top)
        XCTAssertEqual(result11.frame.origin.x, sectionsInsets.left)
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
        
        let sut = createSUT()

        let attributes = sut.viewModel.getAttributesOfItems(at: .zero)

        XCTAssertTrue(attributes.isEmpty)
    }
    
    private func assertAttributes(sut: SUT, rect: CGRect, attributes: [ItemAttributes], file: StaticString = #filePath, line: UInt = #line) {
        
        let sizes = sut.itemsSizesProvider.sizes

        for section in 0..<sizes.count {
            
            let itemsSizes = sizes[section]
            
            for item in 0..<itemsSizes.count {
                
                let itemAttributes = sut.viewModel.getAttributes(section: section, item: item)
                let itemRect = itemAttributes.frame
                let foundItemAttributes = attributes.filter { $0.path == itemAttributes.path }
                
                guard itemRect.intersects(rect) else {
                    
                    XCTAssertEqual(
                        foundItemAttributes.count,
                        0,
                        "Found attribute which must not exist at \(itemAttributes.path)",
                        file: file,
                        line: line
                    )
                    break
                }
                
                XCTAssertEqual(
                    foundItemAttributes.count,
                    1,
                    "Attribute at \(itemAttributes.path) is not found",
                    file: file,
                    line: line
                )
                
                if foundItemAttributes.isEmpty {
                    break
                }
            }
        }
    }
    
    func testGetAttributesOfItemsInRect() {
        
        let itemSize = CGSize(width: 2, height: 2)
        
        let sizes: [[CGSize]] = [
            [
                itemSize,
                itemSize,
            ],
            [
                itemSize,
                itemSize
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
        
        let containerSize = CGSize(
            width: itemSize.width * 2 + sectionInset.left + sectionInset.right + 1,
            height: (itemSize.height + sectionInset.top + sectionInset.bottom) * 2 + 1)
        let sut = createSUT(config: .init(sectionsInsets: sectionInset))

        sut.itemsSizesProvider.sizes = sizes
        
        sut.viewModel.prepare(containerSize: containerSize)
        
        var rectSize = CGSize.zero
        
        while rectSize.width < containerSize.width || rectSize.height < containerSize.height {

            for offsetX in stride(from: 0, through: containerSize.width, by: 1) {

                // Move from the left to the right
                let rectX = CGRect(origin: .init(x: offsetX, y: 0), size: rectSize)

                let attributesX = sut.viewModel.getAttributesOfItems(at: rectX)
                assertAttributes(sut: sut, rect: rectX, attributes: attributesX)

                for offsetY in stride(from: 0, through: containerSize.height, by: 1) {

                    // Move from the top to the bottom
                    let rectY = CGRect(origin: .init(x: 0, y: offsetY), size: rectSize)

                    let attributesY = sut.viewModel.getAttributesOfItems(at: rectY)

                    assertAttributes(sut: sut, rect: rectY, attributes: attributesY)

                    // Move from the top-left corner to the bottom-right corner
                    let rectXY = CGRect(origin: .init(x: offsetX, y: offsetY), size: rectSize)
                    let attributesXY = sut.viewModel.getAttributesOfItems(at: rectXY)

                    assertAttributes(sut: sut, rect: rectXY, attributes: attributesXY)
                }

            }

            rectSize = CGSize(
                width: rectSize.width + 1,
                height: rectSize.height + 1
            )
        }
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
