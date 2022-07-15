//
//  LeftAlignmentPlacer.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 15.07.22.
//

import Foundation

public final class LeftAlignmentPlacer: ItemsPlacer {
    
    private let availableItemsSizesProvider: AvailableItemsSizesProvider
    
    public init(availableItemsSizesProvider: AvailableItemsSizesProvider) {
        
        self.availableItemsSizesProvider = availableItemsSizesProvider
    }
    
    public func fillDirection(limit: DirectionSize) -> [DirectionSize] {
        
        return fillDirection(limit: limit, spacing: 0.0)
    }
    
    public func fillDirection(limit: DirectionSize, spacing: DirectionSize) -> [DirectionSize] {
        
        var result: [DirectionSize] = []
        var availableSpace = limit
        
        var index = 0
        var lastOffset: DirectionSize = 0
        
        while availableSpace > 0 {
            
            let size = availableItemsSizesProvider.getSize(
                index: index,
                availableSpace: availableSpace
            )
            
            guard let size = size else {
                break
            }
            
            if size > availableSpace {
                break
            }
            
            result.append(lastOffset)
            
            lastOffset += (size + spacing)
            index += 1
            availableSpace -= (spacing * DirectionSize(index))
            availableSpace -= size
        }
        
        return result
    }
}
