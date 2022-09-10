//
//  ImportMediaFilesFlowPresenter.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 10.09.2022.
//

import Foundation
import UIKit

public protocol ImportMediaFilesFlowPresenterInput: AnyObject {

    func present(at container: UINavigationController)
    
    func finish()
    
    func dismiss()
}

public protocol ImportMediaFilesFlowPresenter: AnyObject, ImportMediaFilesFlowPresenterInput {}
