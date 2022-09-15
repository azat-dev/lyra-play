//
//  DeleteMediaLibraryItemFlowPresenter.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 15.09.2022.
//

import Foundation
import UIKit

public protocol DeleteMediaLibraryItemFlowPresenterInput: AnyObject {
    
    func present(at container: UINavigationController)
    
    func dismiss()
}

public protocol DeleteMediaLibraryItemFlowPresenter: AnyObject, DeleteMediaLibraryItemFlowPresenterInput {}
