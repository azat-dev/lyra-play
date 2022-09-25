//
//  AddMediaLibraryItemFlowPresenter.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.09.2022.
//

import Foundation
import UIKit

public protocol AddMediaLibraryItemFlowPresenterInput: AnyObject {

    func present(at container: UINavigationController)
    
    func dismiss()
}

public protocol AddMediaLibraryItemFlowPresenter: AddMediaLibraryItemFlowPresenterInput {}
