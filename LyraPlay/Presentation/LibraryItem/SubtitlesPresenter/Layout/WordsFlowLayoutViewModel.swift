//
//  WordsFlowLayoutViewModel.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 14.07.22.
//

import Foundation

public struct ItemPath: Hashable {
    
    public var section: Int
    public var item: Int
    
    public init(section: Int, item: Int) {
        
        self.section = section
        self.item = item
    }
}

public typealias ItemAttributes = (position: Point, size: Size, path: ItemPath)



public final class WordsFlowLayoutViewModel {
    
    public struct Config {
        
        public let sectionsInsets: Insets

        public init(
            sectionsInsets: Insets = .zero
        ) {
            
            self.sectionsInsets = sectionsInsets
        }
    }
    
    private let sizesProvider: ItemsSizesProvider
    private let config: Config
    
    private var cachedAttributes: [ItemAttributes] = [] {

        didSet {
            cachedAttributesDict.removeAll()
            
            for item in cachedAttributes {
                
                cachedAttributesDict[item.path] = item
            }
        }
    }
    
    private var cachedAttributesDict = [ItemPath: ItemAttributes]()
    
    public init(
        sizesProvider: ItemsSizesProvider,
        config: Config? = nil
    ) {
        
        self.sizesProvider = sizesProvider
        self.config = config ?? Config()
    }
    
    private func getItemAttributes(
        path: ItemPath,
        itemSize: Size,
        containerSize: Size,
        offsetX: Double,
        offsetY: Double,
        rowHeight: Double
    ) -> (attributes: ItemAttributes, isNewLine: Bool) {
        
        var position: Point
        let shouldWrap = (offsetX + itemSize.width) > containerSize.width
        
        if shouldWrap {
            
            position = .init(x: 0, y: offsetY + rowHeight)
            
        } else {
            position = .init(x: offsetX, y: offsetY)
        }
        
        let attributes = (
            position,
            itemSize,
            path
        )
        
        return (attributes, shouldWrap)
    }
    
    public func prepare(containerSize: Size) {
        
        var newCachedAttributes: [ItemAttributes] = []
        let numberOfSections = sizesProvider.numberOfSections

        var offsetX = config.sectionsInsets.left
        var offsetY = config.sectionsInsets.top
        var rowHeight = 0.0
        
        for section in 0..<numberOfSections {
        
            let numberOfItems = sizesProvider.numberOfItems(section: section)
            
            for item in 0..<numberOfItems {
                
                let itemSize = sizesProvider.getItemSize(section: section, item: item)
                
                let (attributes, isNewLine) = getItemAttributes(
                    path: ItemPath(section: section, item: item),
                    itemSize: itemSize,
                    containerSize: containerSize,
                    offsetX: offsetX,
                    offsetY: offsetY,
                    rowHeight: rowHeight
                )
                
                newCachedAttributes.append(attributes)
                rowHeight = max(rowHeight, itemSize.height)
                
                if isNewLine {
                    
                    offsetX = attributes.position.x
                    offsetY = attributes.position.y
                } else {
                    
                }
                
                offsetX += attributes.size.width
            }
            
            offsetX = config.sectionsInsets.left
            offsetY += rowHeight + config.sectionsInsets.bottom + config.sectionsInsets.top
            rowHeight = 0
        }
        
        cachedAttributes = newCachedAttributes
    }
    
    public func getAttributes(section: Int, item: Int) -> ItemAttributes {
        
        let path = ItemPath(section: section, item: item)
        return cachedAttributesDict[path]!
    }
}
