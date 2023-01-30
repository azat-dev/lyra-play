//
//  MainTabBarViewModel.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 03.09.2022.
//

import Foundation
import Combine

public enum MainTabBarViewModelTab: Int, Hashable, CaseIterable {
    
    case library
    case dictionary
}

public protocol MainTabBarViewModelDelegate: AnyObject {
    
    func runDictionaryFlow()
    
    func runLibraryFlow()
    
    func runOpenCurrentPlayerStateDetailsFlow()
}

public protocol MainTabBarViewModelInput: AnyObject {

    func selectLibraryTab() -> Void

    func selectDictionaryTab() -> Void
}

public protocol MainTabBarViewModelOutput: AnyObject {
    
    var activeTabIndex: CurrentValueSubject<Int, Never> { get }
    
    var currentPlayerStateViewModel: CurrentValueSubject<CurrentPlayerStateViewModel?, Never> { get }
}

public protocol MainTabBarViewModel: MainTabBarViewModelOutput, MainTabBarViewModelInput {}
