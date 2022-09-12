//
//  MainTabBarViewModel.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 03.09.2022.
//

import Foundation

public protocol MainTabBarViewModelDelegate: AnyObject {
    
    func runDictionaryFlow()
    
    func runLibraryFlow()
}

public protocol MainTabBarViewModelInput: AnyObject {

    func selectLibraryTab() -> Void

    func selectDictionaryTab() -> Void
}

public protocol MainTabBarViewModelOutput: AnyObject {}

public protocol MainTabBarViewModel: MainTabBarViewModelOutput, MainTabBarViewModelInput {}
