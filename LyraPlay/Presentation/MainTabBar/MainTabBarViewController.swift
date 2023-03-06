//
//  MainTabBarViewController.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 03.09.22.
//

import Foundation
import Combine
import UIKit

public final class MainTabBarViewController: UITabBarController, MainTabBarView {
    // MARK: - Properties
    
    private var observers = Set<AnyCancellable>()
    private let viewModel: MainTabBarViewModel
    
    private let tabBarBackgroundView = UIVisualEffectView()
    public var currentPlayerStateView: CurrentPlayerStateView?
    
    private lazy var tabControllers: [MainTabBarViewModelTab: UINavigationController] = {
        
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
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        observers.removeAll()
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

        viewModel.activeTabIndex
            .receive(on: DispatchQueue.main)
            .sink { [weak self] activeTabIndex in

                guard let self = self else {
                    return
                }

                self.selectedIndex = activeTabIndex

            }.store(in: &observers)
        
        viewModel.currentPlayerStateViewModel
            .receive(on: DispatchQueue.main)
            .sink { [weak self] viewModel in
                
                guard let self = self else {
                    return
                }
                
                self.currentPlayerStateView?.removeFromSuperview()
                self.currentPlayerStateView = nil
                
                guard let viewModel = viewModel else {
                    return
                }

                let stateView = CurrentPlayerStateView(viewModel: viewModel)
                self.currentPlayerStateView = stateView
                
                self.view.addSubview(stateView)
                
                Layout.apply(
                    contentView: self.view,
                    tabBar: self.tabBar,
                    currentPlayerStateView: stateView
                )
                
            }.store(in: &observers)
    }
}


// MARK: - TabBarDelegate

extension MainTabBarViewController {
    
    public override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        guard let selecteTabIndex = tabBar.items?.firstIndex(of: item) else {
            return
        }
        
        switch MainTabBarViewModelTab.allCases[selecteTabIndex] {
            
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

        view.insertSubview(tabBarBackgroundView, belowSubview: tabBar)
        viewControllers = MainTabBarViewModelTab.allCases.compactMap { tabControllers[$0] }        
    }
}

// MARK: - Layout
extension MainTabBarViewController {
    
    private func layout() {
        
        Layout.apply(
            contentView: view,
            tabBar: tabBar,
            tabBarBackgroundView: tabBarBackgroundView
        )
    }
}

// MARK: - Styles

extension MainTabBarViewController {
    
    private func style() {
        
        Styles.apply(tabBar: tabBar)
        Styles.apply(tabBarBackground: tabBarBackgroundView)
    }
}
