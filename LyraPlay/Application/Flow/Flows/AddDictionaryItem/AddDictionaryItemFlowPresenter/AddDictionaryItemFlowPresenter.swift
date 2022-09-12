//
//  AddDictionaryItemFlowPresenter.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 12.09.2022.
//

import Foundation
import UIKit

public protocol AddDictionaryItemFlowPresenterInput: AnyObject {

    func present(at container: UINavigationController)
    
    func dismiss()
}

public protocol AddDictionaryItemFlowPresenter: AddDictionaryItemFlowPresenterInput {

}
