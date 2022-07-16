//
//  TimeoutTimer.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 11.07.22.
//

import Foundation

// MARK: - Interfaces

public protocol ActionTimer {
    
    func executeAfter(_ interval: TimeInterval, block: @escaping () async -> Void)
    
    func cancel()
}

public final class DefaultActionTimer: ActionTimer {
    
    private let queue = DispatchQueue(label: "lyraplay.timer", qos: .userInteractive)
    private var workItem: DispatchWorkItem?
    
    public init() {}
    
    public func executeAfter(_ interval: TimeInterval, block: @escaping () async -> Void) {
        
        queue.sync { [weak self] in

            guard let self = self else {
                return
            }
            
            let workItem = DispatchWorkItem { [weak self] in
                
                guard let self = self else {
                    return
                }
                
                Task {
                    await block()
                    self.queue.sync {
                        self.workItem = nil
                    }

                }
            }
            
            self.workItem = workItem
            
            DispatchQueue.global(qos: .userInteractive)
                .asyncAfter(deadline: .now() + interval, execute: workItem)
        }
    }
    
    public func cancel() {

        queue.sync {
            workItem?.cancel()
        }
    }
    
    deinit {
        cancel()
    }
}
