//
//  MessageChannel.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 06.07.22.
//

import Foundation

public final class MessageChannel<Message> {
    
    struct Observer<Message> {
        
        weak var observer: AnyObject?
        weak var queue: DispatchQueue?
        let block: (Message) -> Void
    }
    
    private var observers = [Observer<Message>]()
    
    public init() {}
    
    public func observe(on observer: AnyObject, queue: DispatchQueue?, observerBlock: @escaping (Message) -> Void) {
        let data = Observer(
            observer: observer,
            queue: queue,
            block: observerBlock
        )
        
        observers.append(data)
    }
    
    public func observe(on observer: AnyObject, observerBlock: @escaping (Message) -> Void) {
        observe(on: observer, queue: nil, observerBlock: observerBlock)
    }
    
    public func remove(observer: AnyObject) {
        observers = observers.filter { $0.observer !== observer }
    }
    
    public func send(_ message: Message) {

        for observer in observers {
            
            guard let queue = observer.queue else {
                
                observer.block(message)
                continue
            }
            
            queue.async {
                observer.block(message)
            }
        }
    }
}
