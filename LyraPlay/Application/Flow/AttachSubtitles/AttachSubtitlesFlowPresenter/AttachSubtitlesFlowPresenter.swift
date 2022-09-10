//
//  AttachSubtitlesFlowPresenter.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 10.09.2022.
//

import Foundation
import UIKit

public protocol AttachSubtitlesFlowPresenterInput: AnyObject {

    func present(at container: UINavigationController)
    
    func dismiss()
}

public protocol AttachSubtitlesFlowPresenter: AttachSubtitlesFlowPresenterInput {}
