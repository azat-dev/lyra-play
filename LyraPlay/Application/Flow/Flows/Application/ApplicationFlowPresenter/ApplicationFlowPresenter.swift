//
//  ApplicationFlowPresenter.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 28.01.2023.
//

import Foundation
import UIKit

public protocol ApplicationFlowPresenterInput: AnyObject {

    func present(at container: UIWindow)

    func dismiss()
}

public protocol ApplicationFlowPresenter: ApplicationFlowPresenterInput {

}
