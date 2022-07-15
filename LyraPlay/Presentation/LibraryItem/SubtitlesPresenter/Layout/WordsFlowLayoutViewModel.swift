//
//  WordsFlowLayoutViewModel.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 14.07.22.
//

import Foundation
import UIKit

public typealias ItemAttributes = (frame: CGRect, path: IndexPath)

public final class WordsFlowLayoutViewModel {
    
    public struct Config {
        
        public let sectionsInsets: UIEdgeInsets
        public let sectionFitsToContainer: Bool
        
        public init(
            sectionsInsets: UIEdgeInsets = .zero,
            sectionFitsToContainer: Bool = true
        ) {
            
            self.sectionsInsets = sectionsInsets
            self.sectionFitsToContainer = sectionFitsToContainer
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
    private var cachedSectionAttributesDict = [Int: ItemAttributes]()
    
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
            CGRect(origin: position, size: itemSize),
            path
        )
        
        return (attributes, shouldWrap)
    }
    
    public func prepare(containerSize: CGSize) {
        
        var newCachedAttributes: [ItemAttributes] = []
        var newCachedSectionAttributes = [Int: ItemAttributes]()
        
        let numberOfSections = sizesProvider.numberOfSections
        
        var offsetX = config.sectionsInsets.left
        var offsetY = config.sectionsInsets.top
        var rowHeight = 0.0
        
        var maxRightBoundary = 0.0
        var maxBottomBoundary = 0.0
        
        for section in 0..<numberOfSections {
            
            let numberOfItems = sizesProvider.numberOfItems(section: section)
            var rectOfSectionItems: CGRect? = nil
            
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
                maxRightBoundary = max(maxRightBoundary, attributes.frame.minX + itemSize.width + config.sectionsInsets.right)
                
                if isNewLine {
                    
                    offsetX = attributes.frame.minX
                    offsetY = attributes.frame.minY
                }
                
                offsetX += attributes.frame.width
                
                if let rectOfSectionItemsUnwrapped = rectOfSectionItems {
                    
                    rectOfSectionItems = rectOfSectionItemsUnwrapped.union(attributes.frame)
                } else {
                    rectOfSectionItems = attributes.frame
                }
            }
            
            let bottomOfSection = offsetY + rowHeight + config.sectionsInsets.bottom
            maxBottomBoundary = bottomOfSection
            
            offsetX = config.sectionsInsets.left
            offsetY = bottomOfSection + config.sectionsInsets.top
            rowHeight = 0
            
            if let rectOfSectionItems = rectOfSectionItems {

                let sectionAttributes = calculateSectionAttributes(
                    section: section,
                    numberOfItems: numberOfItems,
                    rectOfSectionItems: rectOfSectionItems,
                    containerSize: containerSize
                )

                if let sectionAttributes = sectionAttributes {
                    newCachedSectionAttributes[section] = sectionAttributes
                }
            }
        }
        
        cachedAttributes = newCachedAttributes
        cachedSectionAttributesDict = newCachedSectionAttributes
        contentSize = CGSize(
            width: maxRightBoundary,
            height: maxBottomBoundary
        )
    }
    
    public func getAttributes(section: Int, item: Int) -> ItemAttributes {
        
        let path = IndexPath(item: item, section: section)
        return cachedAttributesDict[path]!
    }
    
    public func getAttributesOfItems(at rect: CGRect) -> [ItemAttributes] {
        
        var result = [ItemAttributes]()
        let lastIndex = cachedAttributes.count - 1

        guard
            let firstMatchIndex = binarySearch(rect, start: 0, end: lastIndex)
        else {
            return result
        }

        for index in firstMatchIndex...lastIndex {

            let cellAttributes = cachedAttributes[index]

            if rect.intersects(cellAttributes.frame) {
                
                result.append(cellAttributes)
                continue
            }

            if cellAttributes.frame.minY > rect.maxY {
                break
            }
        }

        for index in stride(from: firstMatchIndex - 1, through: 0, by: -1) {

            let cellAttributes = cachedAttributes[index]

            if rect.intersects(cellAttributes.frame) {
                
                result.insert(cellAttributes, at: 0)
                continue
            }
            
            if cellAttributes.frame.maxY < rect.minY {
                break
            }
        }

        return result
    }
    
    private func calculateSectionAttributes(
        section: Int,
        numberOfItems: Int,
        rectOfSectionItems: CGRect,
        containerSize: CGSize
    ) -> ItemAttributes? {
        
        if numberOfItems == 0 {
            return nil
        }
        
        var width: CGFloat
        
        if config.sectionFitsToContainer {
            
            width = containerSize.width
        } else {
            
            width = rectOfSectionItems.width + config.sectionsInsets.left + config.sectionsInsets.right
        }
        
        let frame = CGRect(
            x: rectOfSectionItems.minX - config.sectionsInsets.left,
            y: rectOfSectionItems.minY - config.sectionsInsets.top,
            width: width,
            height: rectOfSectionItems.height + config.sectionsInsets.top + config.sectionsInsets.bottom
        )
        
        return (frame, IndexPath(item: 0, section: section))
    }
    
    public func getSectionAttributes(section: Int) -> ItemAttributes? {

        return cachedSectionAttributesDict[section]
    }
}

extension WordsFlowLayoutViewModel {
    
    private func binarySearch(_ rect: CGRect, start: Int, end: Int) -> Int? {
        
        if end < start {
            return nil
        }
        
        let mid = (start + end) / 2
        let attr = cachedAttributes[mid]
        
        let itemFrame = attr.frame
        let itemYRange = (itemFrame.minY...itemFrame.maxY)
        let rectYRange = (rect.minY...rect.maxY)
        
        if itemYRange.overlaps(rectYRange) {
            return mid
        }
        
        if rect.minY < itemFrame.maxY  {
            return binarySearch(rect, start: start, end: (mid - 1))
        }
        
        return binarySearch(rect, start: (mid + 1), end: end)
    }
}
