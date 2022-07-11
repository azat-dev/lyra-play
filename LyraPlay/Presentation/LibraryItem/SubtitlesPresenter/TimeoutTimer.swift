//
//  TimeoutTimer.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 11.07.22.
//

import Foundation

public final class TimeoutTimer {
    
    let queue = DispatchQueue(label: "lyraplay.timer")
    var workItem: DispatchWorkItem?
    
    private init() {}
    
    public static func create() -> TimeoutTimer {
        return TimeoutTimer()
    }
    
    public func execute(in interval: TimeInterval, block: @escaping () async -> Void) async {
        
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
            
            DispatchQueue.global(qos: .userInteractive).asyncAfter(deadline: .now() + interval, execute: workItem)
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
