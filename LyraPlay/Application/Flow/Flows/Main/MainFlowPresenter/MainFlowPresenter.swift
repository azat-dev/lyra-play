//
//  MainFlowPresenter.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 07.09.22.
//

import Foundation
import UIKit

public protocol MainFlowPresenter: AnyObject {
    
    func present(at: UIWindow)
}
