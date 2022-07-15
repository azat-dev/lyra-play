//
//  LeftAlignmentPlacerTests.swift
//  LyraPlayTests
//
//  Created by Azat Kaiumov on 15.07.22.
//

import Foundation
import XCTest
import LyraPlay

class LeftAlignmentPlacerTests: XCTestCase {
    
    typealias SUT = (
        placer: ItemsPlacer,
        availableItemsSizesProvider: AvailableItemsSizesProviderMock
    )
    
    func createSUT() -> SUT {
        
        let availableItemsSizesProvider = AvailableItemsSizesProviderMock()
        let placer = LeftAlignmentPlacer(availableItemsSizesProvider: availableItemsSizesProvider)
        
        detectMemoryLeak(instance: placer)
        
        return (
            placer,
            availableItemsSizesProvider
        )
    }
    
    func testEmptyItems() {
        
        let sut = createSUT()
        
        let width: DirectionSize = 100
        
        sut.availableItemsSizesProvider.resolveSize = { _, _ in nil}
        let offsets = sut.placer.fillDirection(limit: width)
        
        XCTAssertEqual([], offsets)
    }
    
    func testEmptyItemsWithSpacing() {
        
        let sut = createSUT()
        
        let width: DirectionSize = 100
        let spacing: DirectionSize = 10
        
        sut.availableItemsSizesProvider.resolveSize = { _, _ in nil }
        let offsets = sut.placer.fillDirection(limit: width, spacing: spacing)
        
        XCTAssertEqual([], offsets)
    }
    
    func testFullWidthItems() {
        
        let sut = createSUT()
        
        let width: DirectionSize = 100
        let items: [DirectionSize] = [width, width]
        
        sut.availableItemsSizesProvider.resolveSize = { index, _ in items[index] }
        
        let offsets = sut.placer.fillDirection(limit: width)
        
        let expectedOffsets: [DirectionSize] = [0]
        XCTAssertEqual(expectedOffsets, offsets)
    }
    
    func testFullWidthItemsWithSpacing() {
        
        let sut = createSUT()
        
        let width: DirectionSize = 100
        let spacing: DirectionSize = 10.0
        
        let items: [DirectionSize] = [width, width]
        
        sut.availableItemsSizesProvider.resolveSize = { index, _ in items[index] }
        let offsets = sut.placer.fillDirection(limit: width, spacing: spacing)
        
        let expectedOffsets: [DirectionSize] = [0]
        XCTAssertEqual(expectedOffsets, offsets)
    }
    
    func testWidthOverflow() {
        
        let sut = createSUT()
        
        let width: DirectionSize = 100
        let items: [DirectionSize] = [width / 2, width / 2 + 0.001]
        
        sut.availableItemsSizesProvider.resolveSize = { index, _ in items[index] }
        let offsets = sut.placer.fillDirection(limit: width)
        
        let expectedOffsets: [DirectionSize] = [0]
        XCTAssertEqual(expectedOffsets, offsets)
    }
    
    func testWidthOverflowWithSpacing() {
        
        let sut = createSUT()
        
        let spacing: DirectionSize = 10
        let width: DirectionSize = 100
        
        let items: [DirectionSize] = [width / 2, width / 2]
        
        sut.availableItemsSizesProvider.resolveSize = { index, _ in items[index] }
        let offsets = sut.placer.fillDirection(limit: width, spacing: spacing)
        
        let expectedOffsets: [DirectionSize] = [0]
        XCTAssertEqual(expectedOffsets, offsets)
    }
    
    func testFitMultipleItems() {
        
        let sut = createSUT()
        
        let width: DirectionSize = 100
        let items: [DirectionSize] = [width / 2, width / 2]
        
        sut.availableItemsSizesProvider.resolveSize = { index, _ in items[index] }
        let offsets = sut.placer.fillDirection(limit: width)
        
        let expectedOffsets: [DirectionSize] = [0, width / 2]
        XCTAssertEqual(expectedOffsets, offsets)
    }
    
    func testFitMultipleItemsWithSpacing() {
        
        let sut = createSUT()
        
        let spacing: DirectionSize = 10
        let width: DirectionSize = 100
        
        let itemWidth = (width - spacing) / 2
        let items: [DirectionSize] = [itemWidth, itemWidth]
        
        sut.availableItemsSizesProvider.resolveSize = { index, _ in items[index] }
        let offsets = sut.placer.fillDirection(limit: width, spacing: spacing)
        
        let expectedOffsets: [DirectionSize] = [0, itemWidth + spacing]
        XCTAssertEqual(expectedOffsets, offsets)
    }
}


final class AvailableItemsSizesProviderMock: AvailableItemsSizesProvider {
    
    typealias SizeCallBack = (_ index: Int, _ availableSpace: DirectionSize) -> DirectionSize?
    
    public var resolveSize: SizeCallBack? = nil
    
    func getSize(index: Int, availableSpace: DirectionSize) -> DirectionSize? {
        
        guard let resolveSize = resolveSize else {
            fatalError("Not implemented")
        }

        return resolveSize(index, availableSpace)
    }
}
