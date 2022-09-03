//
//  PresentableModuleFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 03.09.22.
//

import Foundation

public protocol PresentableModuleFactory {
    
    associatedtype ViewFactory: PresentableViewFactory

    func create(viewModel: ViewFactory.ViewModel) -> PresentableModule<ViewFactory.ViewModel, ViewFactory.View>
}

public class PresentableModuleFactoryImpl<VFactory>: PresentableModuleFactory where VFactory: PresentableViewFactory {
    
    // MARK: - Types
    
    public typealias ViewFactory = VFactory
    
    private let viewFactory: ViewFactory
    
    public init(viewFactory: ViewFactory) {
        
        self.viewFactory = viewFactory
    }
    
    public func create(viewModel: VFactory.ViewModel) -> PresentableModule<VFactory.ViewModel, ViewFactory.View> {
        
        let view = viewFactory.create(viewModel: viewModel)
        
        return .init(
            view: view,
            model: viewModel
        )
    }
}
