//
//  SchedulerFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 31.08.22.
//

import Foundation

public protocol SchedulerFactory {
    
    func make() -> Scheduler
}
