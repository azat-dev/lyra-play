//
//  TimeLineIterator.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 13.07.22.
//

import Foundation

public protocol TimeLineIterator {
    
    func beginExecution(from: TimeInterval) -> TimeInterval?
    
    func getNextEventTime() -> TimeInterval?
    
    func moveToNextEvent() -> TimeInterval?
    
    var lastEventTime: TimeInterval? { get }
}
