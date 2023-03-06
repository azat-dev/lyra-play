//
//  MainFlowPresenterImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 07.09.22.
//

import Foundation
import UIKit
import Combine

public final class MainFlowPresenterImpl: MainFlowPresenter {
    

    // MARK: - Properties
    
    private let mainFlowModel: MainFlowModel
    private let mainTabBarViewFactory: MainTabBarViewFactory
    
    private let libraryFlowPresenterFactory: LibraryFolderFlowPresenterFactory
    private let dictionaryFlowPresenterFactory: DictionaryFlowPresenterFactory
    private let currentPlayerStateDetailsFlowPresenterFactory: CurrentPlayerStateDetailsFlowPresenterFactory
    
    private var libraryFlowPresenter: LibraryFolderFlowPresenter?
    private var libraryFlowObserver: AnyCancellable?
    
    private var dictionaryFlowPresenter: DictionaryFlowPresenter?
    private var currentPlayerStateDetailsPresenter: CurrentPlayerStateDetailsFlowPresenter?
    
    private var observers = Set<AnyCancellable>()
    
    
    // MARK: - Initializers
    
    public init(
        mainFlowModel: MainFlowModel,
        mainTabBarViewFactory: MainTabBarViewFactory,
        libraryFlowPresenterFactory: LibraryFolderFlowPresenterFactory,
        dictionaryFlowPresenterFactory: DictionaryFlowPresenterFactory,
        currentPlayerStateDetailsFlowPresenterFactory: CurrentPlayerStateDetailsFlowPresenterFactory
    ) {
        
        self.mainFlowModel = mainFlowModel
        self.mainTabBarViewFactory = mainTabBarViewFactory
        self.libraryFlowPresenterFactory = libraryFlowPresenterFactory
        self.dictionaryFlowPresenterFactory = dictionaryFlowPresenterFactory
        self.currentPlayerStateDetailsFlowPresenterFactory = currentPlayerStateDetailsFlowPresenterFactory
    }
    
    deinit {
        observers.removeAll()
    }
}

// MARK: - Methods

extension MainFlowPresenterImpl {
    
    public func present(at container: UIWindow) {

        let rootNavigationContainer = UINavigationController()
        rootNavigationContainer.navigationBar.isHidden = true
        
        let mainTabBarView = mainTabBarViewFactory.make(viewModel: mainFlowModel.mainTabBarViewModel)
        
        mainFlowModel.libraryFlow
            .receive(on: DispatchQueue.main)
            .sink { [weak self] libraryFlow in
                
                guard let self = self else {
                    return
                }
                
                guard
                    let libraryFlow = libraryFlow,
                    self.libraryFlowPresenter == nil
                else {
                    return
                }
                
                let presenter = self.libraryFlowPresenterFactory.make(for: libraryFlow)
                presenter.present(at: mainTabBarView.libraryContainer)
                
                self.libraryFlowPresenter = presenter
            }.store(in: &observers)
        
        
        mainFlowModel.dictionaryFlow
            .receive(on: DispatchQueue.main)
            .sink { [weak self]  dictionaryFlow in
                
                guard let self = self else {
                    return
                }
                
                guard
                    let dictionaryFlow = dictionaryFlow,
                    self.dictionaryFlowPresenter == nil
                else {
                    return
                }
                
                let presenter = self.dictionaryFlowPresenterFactory.make(for: dictionaryFlow)
                presenter.present(at: mainTabBarView.dictionaryContainer)
                
                self.dictionaryFlowPresenter = presenter
            }.store(in: &observers)
        
        mainFlowModel.currentPlayerStateDetailsFlow
            .receive(on: DispatchQueue.main)
            .sink { [weak self] currentPlayerStateDetailsFlow in
                
                guard let self = self else {
                    return
                }
                
                guard let flow = currentPlayerStateDetailsFlow else {
                    
                    self.currentPlayerStateDetailsPresenter?.dismiss()
                    self.currentPlayerStateDetailsPresenter = nil
                    return
                }
                
                let presenter = self.currentPlayerStateDetailsFlowPresenterFactory.make(for: flow)
                
                self.currentPlayerStateDetailsPresenter = presenter
                presenter.present(at: rootNavigationContainer)
            }
            .store(in: &observers)
        
        rootNavigationContainer.setRoot(mainTabBarView)
        container.setRoot(rootNavigationContainer)
    }
}
