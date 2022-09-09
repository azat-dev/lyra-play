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
    
    private let libraryFlowPresenterFactory: LibraryFlowPresenterFactory
    private let dictionaryFlowPresenterFactory: DictionaryFlowPresenterFactory
    
    private var libraryFlowPresenter: LibraryFlowPresenter?
    private var libraryFlowObserver: AnyCancellable?
    
    private var dictionaryFlowPresenter: DictionaryFlowPresenter?
    private var dictionaryFlowObserver: AnyCancellable?
    
    
    // MARK: - Initializers
    
    public init(
        mainFlowModel: MainFlowModel,
        mainTabBarViewFactory: MainTabBarViewFactory,
        libraryFlowPresenterFactory: LibraryFlowPresenterFactory,
        dictionaryFlowPresenterFactory: DictionaryFlowPresenterFactory
    ) {
        
        self.mainFlowModel = mainFlowModel
        self.mainTabBarViewFactory = mainTabBarViewFactory
        self.libraryFlowPresenterFactory = libraryFlowPresenterFactory
        self.dictionaryFlowPresenterFactory = dictionaryFlowPresenterFactory
    }
    
    // MARK: - Methods
    
    public func present(at container: WindowContainer) {
        
        let mainTabBarView = mainTabBarViewFactory.create(viewModel: mainFlowModel.mainTabBarViewModel)
        
        libraryFlowObserver = mainFlowModel.libraryFlow
            .receive(on: RunLoop.main)
            .sink { [weak self] libraryFlow in
                
                guard
                    let self = self,
                    let libraryFlow = libraryFlow,
                    self.libraryFlowPresenter == nil
                else {
                    return
                }
                
                let presenter = self.libraryFlowPresenterFactory.create(for: libraryFlow)
                presenter.present(at: mainTabBarView.libraryContainer)
                
                self.libraryFlowPresenter = presenter
            }
        
        
        dictionaryFlowObserver = mainFlowModel.dictionaryFlow
            .receive(on: RunLoop.main)
            .sink { [weak self] dictionaryFlow in
                
                guard
                    let self = self,
                    let dictionaryFlow = dictionaryFlow,
                    self.dictionaryFlowPresenter == nil
                else {
                    return
                }
                
                let presenter = self.dictionaryFlowPresenterFactory.create(for: dictionaryFlow)
                presenter.present(at: mainTabBarView.dictionaryContainer)
                
                self.dictionaryFlowPresenter = presenter
            }
        
        container.setRoot(mainTabBarView)
    }
}
