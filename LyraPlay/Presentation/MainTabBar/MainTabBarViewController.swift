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
        
        let libraryView = UINavigationController()
        libraryView.navigationBar.prefersLargeTitles = true
        
        libraryView.tabBarItem = .init(
            title: "Library",
            image: .init(systemName: "books.vertical"),
            selectedImage: .init(systemName: "books.vertical.fill")
        )
        
        let dictionaryView = UINavigationController()
        dictionaryView.navigationBar.prefersLargeTitles = true
        
        dictionaryView.tabBarItem = .init(
            title: "Dictionary",
            image: .init(systemName: "character.book.closed"),
            selectedImage: .init(systemName: "character.book.closed.fill")
        )
        
        return [
            .library: libraryView,
            .dictionary: dictionaryView
        ]
    } ()
    
    public var libraryContainer: UINavigationController {
        return tabControllers[.library]!
    }
    
    public var dictionaryContainer: UINavigationController {
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
        
        guard let selecteTabIndex = tabBar.items?.firstIndex(of: item) else {
            return
        }
        
        switch Tab.allCases[selecteTabIndex] {
            
        case .dictionary:
            viewModel.selectDictionaryTab()
            
        case .library:
            viewModel.selectLibraryTab()
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
    
    private func layout() {}
}

// MARK: - Styles

extension MainTabBarViewController {
    
    private func style() {
        
        Styles.apply(tabBar: tabBar)
    }
}
