//
//  TimeLineIterator.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 13.07.22.
//

import Foundation

public protocol TimeLineIterator {
    
    func move(at: TimeInterval) -> TimeInterval?
    
    func getNext() -> TimeInterval?
    
    func next() -> TimeInterval?
    
    var currentTime: TimeInterval? { get }
}
