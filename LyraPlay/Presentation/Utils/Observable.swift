//
//  Observable.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 27.06.22.
//

import Foundation

public final class ObserverToken {
    public init() {}
}

public final class Observable<Value> {

    struct Observer<Value> {
        
        weak var observer: AnyObject?
        weak var queue: DispatchQueue?
        let block: (Value) -> Void
    }
    
    private var observers = [Observer<Value>]()
    
    public var value: Value {
        didSet {
            notifyObservers()
        }
    }
    
    public init(_ value: Value) {
        self.value = value
    }
    
    public func observe(on observer: AnyObject, queue: DispatchQueue?, observerBlock: @escaping (Value) -> Void) {
        let data = Observer(
            observer: observer,
            queue: queue,
            block: observerBlock
        )
        
        observers.append(data)
        observerBlock(self.value)
    }
    
    public func observe(on observer: AnyObject, observerBlock: @escaping (Value) -> Void) {
        observe(on: observer, queue: nil, observerBlock: observerBlock)
    }
    
    public func remove(observer: AnyObject) {
        observers = observers.filter { $0.observer !== observer }
    }
    
    private func notifyObservers() {

        let currentValue = self.value
        
        for observer in observers {
            
            guard let queue = observer.queue else {
                
                observer.block(currentValue)
                continue
            }
            
            queue.async {
                observer.block(currentValue)
            }
        }
    }
}
