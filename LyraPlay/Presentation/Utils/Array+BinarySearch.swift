//
//  Array+BinarySearch.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 22.03.23.
//

import Foundation

extension Array {
    
    func binarySearch(range: Range<Int>, comparator: (Element) -> ComparisonResult) -> Int? {
        
        if range.lowerBound >= range.upperBound {
            // If we get here, then the search key is not present in the array.
            return nil

        }

        let midIndex = range.lowerBound + (range.upperBound - range.lowerBound) / 2
        
        let comparisionResult = comparator(self[midIndex])
        
        if comparisionResult == .orderedAscending {
            return binarySearch(
                range: range.lowerBound ..< midIndex,
                comparator: comparator
            )
        }
        
        if comparisionResult == .orderedDescending {
            
            return binarySearch(
                range: midIndex + 1 ..< range.upperBound,
                comparator: comparator
            )
        }
        
        return midIndex
    }
}
