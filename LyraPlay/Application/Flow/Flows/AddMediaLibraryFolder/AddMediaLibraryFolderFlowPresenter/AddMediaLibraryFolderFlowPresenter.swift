//
//  AddMediaLibraryFolderFlowPresenter.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 20.09.2022.
//

import Foundation
import UIKit

public protocol AddMediaLibraryFolderFlowPresenterInput: AnyObject {

    func present(at container: UINavigationController)

    func dismiss()
}

public protocol AddMediaLibraryFolderFlowPresenter: AddMediaLibraryFolderFlowPresenterInput {}
