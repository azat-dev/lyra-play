//
//  DictionaryFlowPresenterFactory.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 08.09.22.
//

import Foundation

public protocol DictionaryFlowPresenterFactory {
    
    func make(for flowModel: DictionaryFlowModel) -> DictionaryFlowPresenter
}
