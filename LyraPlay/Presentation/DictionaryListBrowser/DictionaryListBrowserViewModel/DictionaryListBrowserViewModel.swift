//
//  DictionaryListBrowserViewModel.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 05.09.2022.
//

import Foundation
import Combine

public enum DictionaryListBrowserChangeEvent: Equatable {

    case loaded(items: [DictionaryListBrowserItemViewModel])
}

public protocol DictionaryListBrowserViewModelInput {

    func load() async

    func addNewItem()
}

public protocol DictionaryListBrowserViewModelOutput {

    var isLoading: CurrentValueSubject<Bool, Never> { get }

    var listChanged: PassthroughSubject<DictionaryListBrowserChangeEvent, Never> { get }
}

public protocol DictionaryListBrowserViewModel: DictionaryListBrowserViewModelOutput, DictionaryListBrowserViewModelInput {

}
