//
//  MainTabBarViewModel.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 03.09.2022.
//

import Foundation

public protocol MainTabBarViewModelDelegate {
    
    func runDictionaryFlow()
    
    func runLibraryFlow()
}

public protocol MainTabBarViewModelInput {

    func selectLibraryTab() -> Void

    func selectDictionaryTab() -> Void
}

public protocol MainTabBarViewModelOutput {}

public protocol MainTabBarViewModel: MainTabBarViewModelOutput, MainTabBarViewModelInput {}
