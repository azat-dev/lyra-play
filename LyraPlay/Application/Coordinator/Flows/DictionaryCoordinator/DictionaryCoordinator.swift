//
//  DictionaryCoordinator.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 05.09.2022.
//

public protocol DictionaryCoordinatorInput: AnyObject {
    
    func runCreationFlow(completion: (_ newItem: DictionaryItem?) -> Void)
}

public protocol DictionaryCoordinator: Coordinator, DictionaryCoordinatorInput {
    
    func start(at: StackPresentationContainer)
}
