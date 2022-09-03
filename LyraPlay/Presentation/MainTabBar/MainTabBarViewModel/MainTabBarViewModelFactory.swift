//
//  MainTabBarViewModelFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 03.09.2022.
//

public protocol MainTabBarViewModelFactory {

    associatedtype ViewModel: MainTabBarViewModel

    func create(coordinator: MainTabBarCoordinator) -> ViewModel
}