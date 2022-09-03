//
//  MainTabBarViewFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 03.09.2022.
//

public protocol MainTabBarViewFactory: PresentableViewFactory
	where ViewModel: MainTabBarViewModel, View: MainTabBarView {}