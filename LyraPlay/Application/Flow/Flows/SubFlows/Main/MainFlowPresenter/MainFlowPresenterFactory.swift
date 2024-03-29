//
//  MainFlowPresenterFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 28.01.23.
//

import Foundation

public protocol MainFlowPresenterFactory {
 
    func make(flowModel: MainFlowModel) -> MainFlowPresenter
}
