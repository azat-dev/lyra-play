//
//  DictionaryListBrowserViewModel.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 05.09.2022.
//

import Foundation
import Combine

public protocol DictionaryListBrowserViewModelDelegate: AnyObject {
    
    func runCreationFlow()
}

public enum DictionaryListBrowserChangeEvent: Equatable {
    
    case loaded(items: [DictionaryListBrowserItemViewModel])
}

public protocol DictionaryListBrowserViewModelInput: AnyObject {
    
    func load() async
    
    func addNewItem()
    
    func deleteItem()
}

public protocol DictionaryListBrowserViewModelOutput: AnyObject {
    
    var isLoading: CurrentValueSubject<Bool, Never> { get }
    
    var listChanged: PassthroughSubject<DictionaryListBrowserChangeEvent, Never> { get }
}

public protocol DictionaryListBrowserViewModel: DictionaryListBrowserViewModelOutput, DictionaryListBrowserViewModelInput {}
