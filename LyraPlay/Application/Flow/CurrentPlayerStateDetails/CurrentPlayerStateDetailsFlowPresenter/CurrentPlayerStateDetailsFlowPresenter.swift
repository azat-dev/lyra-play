//
//  CurrentPlayerStateDetailsFlowPresenter.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 30.09.2022.
//

import Foundation
import UIKit

public protocol CurrentPlayerStateDetailsFlowPresenterInput: AnyObject {

    func present(at container: UINavigationController)

    func dismiss()
}

public protocol CurrentPlayerStateDetailsFlowPresenter: CurrentPlayerStateDetailsFlowPresenterInput {}
