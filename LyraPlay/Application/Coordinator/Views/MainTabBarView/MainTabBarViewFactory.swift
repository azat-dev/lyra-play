//
//  MainTabBarViewFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 03.09.2022.
//

public protocol MainTabBarViewFactory {
    
    func create(viewModel: MainTabBarViewModel) -> MainTabBarView
}
