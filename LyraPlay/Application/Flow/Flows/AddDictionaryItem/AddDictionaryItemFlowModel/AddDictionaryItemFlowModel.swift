//
//  AddDictionaryItemFlowModel.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 12.09.2022.
//

import Foundation
import Combine

public protocol AddDictionaryItemFlowModelDelegate {
    
}

public protocol AddDictionaryItemFlowModelInput: AnyObject {
}

public protocol AddDictionaryItemFlowModelOutput: AnyObject {

    var editDictionaryItemViewModel: CurrentValueSubject<EditDictionaryItemViewModel?, Never> { get }
}

public protocol AddDictionaryItemFlowModel: AddDictionaryItemFlowModelOutput, AddDictionaryItemFlowModelInput {}
