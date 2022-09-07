//
//  DictionaryFlowModel.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 07.09.2022.
//

import Foundation

public protocol DictionaryFlowModelInput {

}

public protocol DictionaryFlowModelOutput {

    var listViewModel: DictionaryListBrowserViewModel { get }
}

public protocol DictionaryFlowModel: DictionaryFlowModelOutput, DictionaryFlowModelInput {

}
