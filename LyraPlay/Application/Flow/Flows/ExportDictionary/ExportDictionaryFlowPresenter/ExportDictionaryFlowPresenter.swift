//
//  ExportDictionaryFlowPresenter.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.01.2023.
//

import Foundation
import UIKit

public protocol ExportDictionaryFlowPresenterInput: AnyObject {

    func present(at container: UINavigationController)

    func dismiss()
}

public protocol ExportDictionaryFlowPresenter: AnyObject, ExportDictionaryFlowPresenterInput {

}
