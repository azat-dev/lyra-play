//
//  ImportMediaFilesFlowPresenterImpl.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 10.09.2022.
//

import Foundation
import Combine
import UIKit

public final class ImportMediaFilesFlowPresenterImpl: ImportMediaFilesFlowPresenter {
    
    // MARK: - Properties
    
    private let flowModel: ImportMediaFilesFlowModel
    private let filesPickerViewFactory: FilesPickerViewFactory
    
    private weak var activePickerView: UIViewController?
    private var observers = Set<AnyCancellable>()
    
    // MARK: - Initializers
    
    public init(
        flowModel: ImportMediaFilesFlowModel,
        filesPickerViewFactory: FilesPickerViewFactory
    ) {
        
        self.flowModel = flowModel
        self.filesPickerViewFactory = filesPickerViewFactory
    }
    
    deinit {
        observers.removeAll()
    }
}

// MARK: - Input Methods

extension ImportMediaFilesFlowPresenterImpl {
    
    public func present(at container: UINavigationController) {
        
        flowModel.filesPickerViewModel
            .receive(on: DispatchQueue.main)
            .sink { [weak self] filesPickerViewModel in
                
                guard let self = self else {
                    return
                }
                
                guard let filesPickerViewModel = filesPickerViewModel else {
                    
                    self.activePickerView?.dismiss(animated: true)
                    self.activePickerView = nil
                    return
                }
                
                let view = self.filesPickerViewFactory.make(viewModel: filesPickerViewModel)
                self.activePickerView = view
                container.present(view, animated: true)
            }.store(in: &observers)
    }
    
    public func dismiss() {
        
        activePickerView?.dismiss(animated: true)
        activePickerView = nil
    }
}
