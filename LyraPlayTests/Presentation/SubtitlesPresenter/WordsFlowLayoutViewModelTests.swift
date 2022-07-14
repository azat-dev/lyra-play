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
        itemSizesProvider: ItemsSizesProvider
    )
    
    func createSUT() -> SUT {
        
        let itemsSizesProvider = ItemsSizesProviderMock()
        let interItemSpace = 0
        let spaceBetweenLines = 0
        
        let viewModel = WordsFlowLayoutViewModel(
            itemsSizesProvider: itemsSizesProvider,
            interItemSpace: interItemSpace,
            spaceBetweenLines: spaceBetweenLines
        )
        
        detectMemoryLeak(instance: viewModel)
        
        return viewModel
    }
    
    func testEachSectionFromNewLine() {
        
        let testWidth = 1
        let itemSize = CGSize(width: 1, height: 1)
        let interItemSpace = 0
        let spaceBetweenLines = 0
        
        let testContainerSize = CGSize(width: 10, height: 10)
        let sut = createSUT()
        
        let numberOfSections = 3
        
        sut.itemSizesProvider.sizes = (0..<numberOfSections).map { _ in [itemSize] }
        
        sut.viewModel.prepare(containerSize: testContainerSize)

        var prevOffsetY = -itemSize.height
        
        for section in 0..<numberOfSections {
            
            let (position, size) = sut.viewModel.getAttributes(section: section, item: 0)
            
            XCTAssertEqual(position.y, prevOffsetY + itemSize.height)
            prevOffsetY = position.y
        }
    }
}

// MARK: - Mocks

protocol ItemsSizesProvider {
    
    func getItemSize(section: Int, item: Int) -> CGSize
    
    var numberOfSections: Int { get }
    
    func numberOfItems(section: Int) -> Int
}

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
