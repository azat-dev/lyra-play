//
//  WordsFlowLayoutViewModel.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 14.07.22.
//

import Foundation
import UIKit

public typealias ItemAttributes = (position: CGPoint, size: CGSize, path: IndexPath)

public final class WordsFlowLayoutViewModel {
    
    public struct Config {
        
        public let sectionsInsets: UIEdgeInsets

        public init(
            sectionsInsets: UIEdgeInsets = .zero
        ) {
            
            self.sectionsInsets = sectionsInsets
        }
    }
    
    public var contentSize = CGSize.zero
    
    private let sizesProvider: ItemsSizesProvider
    private let config: Config
    
    private var cachedAttributes: [ItemAttributes] = [] {

        didSet {
            cachedAttributesDict.removeAll()
            cachedAttributesDict.reserveCapacity(cachedAttributes.count)
            
            for item in cachedAttributes {
                
                cachedAttributesDict[item.path] = item
            }
        }
    }
    
    private var cachedAttributesDict = [IndexPath: ItemAttributes]()
    
    public init(
        sizesProvider: ItemsSizesProvider,
        config: Config? = nil
    ) {
        
        self.sizesProvider = sizesProvider
        self.config = config ?? Config()
    }
    
    private func getItemAttributes(
        path: IndexPath,
        itemSize: CGSize,
        containerSize: CGSize,
        offsetX: CGFloat,
        offsetY: CGFloat,
        rowHeight: CGFloat,
        sectionInsets: UIEdgeInsets
    ) -> (attributes: ItemAttributes, isNewLine: Bool) {
        
        var position: CGPoint
        let shouldWrap = (offsetX + itemSize.width) > (containerSize.width - sectionInsets.right)
        
        if shouldWrap {
            
            position = .init(x: sectionInsets.left, y: offsetY + rowHeight)
            
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
    
    public func prepare(containerSize: CGSize) {
        
        var newCachedAttributes: [ItemAttributes] = []
        
        let numberOfSections = sizesProvider.numberOfSections

        var offsetX = config.sectionsInsets.left
        var offsetY = config.sectionsInsets.top
        var rowHeight = 0.0
        
        var maxRightBoundary = 0.0
        var maxBottomBoundary = 0.0
        
        for section in 0..<numberOfSections {
        
            let numberOfItems = sizesProvider.numberOfItems(section: section)
            
            for item in 0..<numberOfItems {
                
                let itemSize = sizesProvider.getItemSize(section: section, item: item)
                
                let (attributes, isNewLine) = getItemAttributes(
                    path: IndexPath(item: item, section: section),
                    itemSize: itemSize,
                    containerSize: containerSize,
                    offsetX: offsetX,
                    offsetY: offsetY,
                    rowHeight: rowHeight,
                    sectionInsets: config.sectionsInsets
                )
                
                newCachedAttributes.append(attributes)
                rowHeight = max(rowHeight, itemSize.height)
                maxRightBoundary = max(maxRightBoundary, attributes.position.x + itemSize.width + config.sectionsInsets.right)
                
                if isNewLine {
                    
                    offsetX = attributes.position.x
                    offsetY = attributes.position.y
                } else {
                    
                }
                
                offsetX += attributes.size.width
            }
            
            let bottomOfSection = offsetY + rowHeight + config.sectionsInsets.bottom
            maxBottomBoundary = bottomOfSection
            
            offsetX = config.sectionsInsets.left
            offsetY = bottomOfSection + config.sectionsInsets.top
            rowHeight = 0
        }
        
        
        cachedAttributes = newCachedAttributes
        contentSize = CGSize(
            width: maxRightBoundary,
            height: maxBottomBoundary
        )
    }
    
    public func getAttributes(section: Int, item: Int) -> ItemAttributes {
        
        let path = IndexPath(item: item, section: section)
        return cachedAttributesDict[path]!
    }
    
    public func getAttributesOfItems(at: CGRect) -> [ItemAttributes] {
        return []
    }
}
