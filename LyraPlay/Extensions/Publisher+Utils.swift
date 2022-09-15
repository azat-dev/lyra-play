//
//  Publisher+Utils.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 17.08.22.
//

import Foundation
import Combine

public final class PublisherSessionToken {
    init() {}
}

public final class PublisherSession {
    
    private var hash: AnyObject = PublisherSessionToken()
    
    public init() {}
    
    public func memorize() -> AnyObject {
        return hash
    }
    
    public func update() {
        hash = PublisherSessionToken()
    }
    
    public func isChanged(_ hash: AnyObject) -> Bool {
        return self.hash !== hash
    }
}

public struct PublisherFlowIsChanged: Error { }

public class PublisherWithSession<Output, Failure> where Failure: Error {
    
    public let publisher: CurrentValueSubject<Output, Failure>
    public let session: PublisherSession = PublisherSession()
    
    public var value: Output {
        set {
            session.update()
            publisher.value = newValue
        }
        
        get { publisher.value }
    }
    
    public init(_ value: Output) {
        publisher = CurrentValueSubject(value)
    }
    
    public func send(_ value: Output) throws {
        
        let memorizedSession = session.memorize()
        
        publisher.value = value
        
        if session.isChanged(memorizedSession) {
            throw PublisherFlowIsChanged()
        }
    }
}
