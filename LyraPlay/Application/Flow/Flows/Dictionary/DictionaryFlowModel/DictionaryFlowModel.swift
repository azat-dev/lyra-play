//
//  DictionaryFlowModel.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 07.09.2022.
//

import Foundation
import Combine

public protocol DictionaryFlowModelInput {

}

public protocol DictionaryFlowModelOutput {

    var listViewModel: DictionaryListBrowserViewModel { get }
    
    var addDictionaryItemFlow: CurrentValueSubject<AddDictionaryItemFlowModel?, Never> { get }
}

public protocol DictionaryFlowModel: DictionaryFlowModelOutput, DictionaryFlowModelInput {

}
