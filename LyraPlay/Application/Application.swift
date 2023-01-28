//
//  Application.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 05.09.22.
//

import Foundation
import CoreData
import UIKit

public class Application {
    
    // MARK: - Properties
    
    private let settings: ApplicationSettings
    
    private let flowModelFactory: ApplicationFlowModelFactory
    private let flowPresenterFactory: ApplicationFlowPresenterFactory
    
    private var presenter: ApplicationFlowPresenter?
    
    // MARK: - Initializers
    
    public init(
        settings: ApplicationSettings,
        flowModelFactory: ApplicationFlowModelFactory,
        flowPresenterFactory: ApplicationFlowPresenterFactory
    ) {
        
        self.settings = settings
        self.flowModelFactory = flowModelFactory
        self.flowPresenterFactory = flowPresenterFactory
    }
    
    // MARK: - Methods
    
    public func start(container: UIWindow) {
        
        let model = flowModelFactory.create()
        let presenter = flowPresenterFactory.create(for: model)
        
        self.presenter = presenter
        
        presenter.present(at: container)
    }
}
