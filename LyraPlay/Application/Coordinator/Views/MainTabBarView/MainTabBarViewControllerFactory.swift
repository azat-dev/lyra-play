//
//  MainTabBarViewControllerFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 03.09.2022.
//

import Foundation

public final class MainTabBarViewControllerFactory<ViewModel>: MainTabBarViewFactory
    where ViewModel: MainTabBarViewModel {
    
    public typealias View = MainTabBarViewController
    
    public typealias ViewModel = ViewModel

    // MARK: - Initializers

    public init() {}

    // MARK: - Methods

    public func create(viewModel: ViewModel) -> View {

        return MainTabBarViewController(viewModel: viewModel)
    }
}
