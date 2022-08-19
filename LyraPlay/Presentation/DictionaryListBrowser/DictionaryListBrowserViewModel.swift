//
//  DictionaryListBrowserViewModel.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.08.2022.
//

import Foundation
import Combine

// MARK: - Interfaces

public protocol DictionaryListBrowserCoordinator {
    
}

public enum DictionaryListBrowserChangeEvent: Equatable {

    case loaded(items: [DictionaryListBrowserItemViewModel])
}

public struct DictionaryListBrowserItemViewModel: Equatable {

    public var title: String
    public var description: String

    public init(
        title: String,
        description: String
    ) {

        self.title = title
        self.description = description
    }
}

public protocol DictionaryListBrowserViewModelInput {

    func load()
}


public protocol DictionaryListBrowserViewModelOutput {

    var isLoading: CurrentValueSubject<Bool, Never> { get }

    var listChanged: PassthroughSubject<DictionaryListBrowserChangeEvent, Never> { get }
}

public protocol DictionaryListBrowserViewModel: DictionaryListBrowserViewModelOutput, DictionaryListBrowserViewModelInput {
}

// MARK: - Implementations

public final class DefaultDictionaryListBrowserViewModel: DictionaryListBrowserViewModel {

    // MARK: - Properties

    private let dictionaryListBrowserCoordinator: DictionaryListBrowserCoordinator
    private let browseDictionaryUseCase: BrowseDictionaryUseCase

    public let isLoading = CurrentValueSubject<Bool, Never>(true)
    public let listChanged: PassthroughSubject<DictionaryListBrowserChangeEvent, Never> = .init()

    // MARK: - Initializers

    public init(
        dictionaryListBrowserCoordinator: DictionaryListBrowserCoordinator,
        browseDictionaryUseCase: BrowseDictionaryUseCase
    ) {

        self.dictionaryListBrowserCoordinator = dictionaryListBrowserCoordinator
        self.browseDictionaryUseCase = browseDictionaryUseCase
    }
}

// MARK: - Input Methods

extension DefaultDictionaryListBrowserViewModel {

    public func load() {
        
    }
}