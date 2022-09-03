//
//  MainTabBarViewController.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 03.09.22.
//

import Foundation
import UIKit

public final class MainTabBarViewController: UITabBarController, MainTabBarView {
    
    private enum Tab: Int, Hashable, CaseIterable {
        
        case library
        case dictionary
    }
    
    // MARK: - Properties
    
    private let viewModel: MainTabBarViewModel
    
    private lazy var tabControllers: [Tab: UINavigationController] = {
        
        return [
            .library: UINavigationController(),
            .dictionary: UINavigationController()
        ]
    } ()
    
    public var libraryContainer: StackPresentationContainer {
        return tabControllers[.library]!
    }
    
    public var dictionaryContainer: StackPresentationContainer {
        return tabControllers[.dictionary]!
    }
    

    // MARK: - Initializers
    
    init(viewModel: MainTabBarViewModel) {
        
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    private func setup() {
        
        setupViews()
        style()
        layout()
        bind(to: viewModel)
    }
}

// MARK: - Bind viewModel

extension MainTabBarViewController {
    
    private func bind(to viewModel: MainTabBarViewModel) {
    }
}


// MARK: - TabBarDelegate

extension MainTabBarViewController {

    public override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {

        switch Tab(rawValue: selectedIndex) {
        
        case .dictionary:
            viewModel.selectDictionaryTab()
        
        case .library:
            viewModel.selectLibraryTab()
            
        case .none:
            break
        }
    }
}

// MARK: - Setup Views

extension MainTabBarViewController {
    
    private func setupViews() {
        
        viewControllers = Tab.allCases.compactMap { tabControllers[$0] }
    }
}

// MARK: - Layout
extension MainTabBarViewController {
    
    private func layout() {
    }
}

// MARK: - Styles

extension MainTabBarViewController {
    
    private func style() {
    }
}

