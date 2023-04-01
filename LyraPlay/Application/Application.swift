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
    private let deepLinksModelFactory: DeepLinksHandlerFlowModelFactory
    
    private var presenter: ApplicationFlowPresenter?
    private var deepLinksFlowModel: DeepLinksHandlerFlowModel?
    
    // MARK: - Initializers
    
    public init(
        settings: ApplicationSettings,
        flowModelFactory: ApplicationFlowModelFactory,
        flowPresenterFactory: ApplicationFlowPresenterFactory,
        deepLinksModelFactory: DeepLinksHandlerFlowModelFactory
    ) {
        
        self.settings = settings
        self.flowModelFactory = flowModelFactory
        self.flowPresenterFactory = flowPresenterFactory
        self.deepLinksModelFactory = deepLinksModelFactory
    }
    
    // MARK: - Methods
    
    public func start(container: UIWindow) {
        
        let applicationModel = flowModelFactory.make()
        deepLinksFlowModel = deepLinksModelFactory.make(applicationFlowModel: applicationModel)
        
        let presenter = flowPresenterFactory.make(for: applicationModel)
        self.presenter = presenter
        
        presenter.present(at: container)
    }
    
    public func openDeepLinks(urls: [URL]) {

        deepLinksFlowModel?.handle(urls: urls)
    }
}
