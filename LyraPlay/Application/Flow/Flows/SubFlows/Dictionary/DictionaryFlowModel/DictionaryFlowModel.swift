//
//  DictionaryFlowModel.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 07.09.2022.
//

import Foundation
import Combine


public protocol DictionaryFlowModelOutput {

    var listViewModel: DictionaryListBrowserViewModel { get }
    
    var addDictionaryItemFlow: CurrentValueSubject<AddDictionaryItemFlowModel?, Never> { get }
    
    var exportDictionaryFlow: CurrentValueSubject<ExportDictionaryFlowModel?, Never> { get }
    
    var deleteDictionaryItemFlow: CurrentValueSubject<DeleteDictionaryItemFlowModel?, Never> { get }
}

public protocol DictionaryFlowModelInput {
    
}

public protocol DictionaryFlowModel: DictionaryFlowModelOutput, DictionaryFlowModelInput {}
