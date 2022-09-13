//
//  DeleteDictionaryItemFlowModel.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 13.09.2022.
//

import Foundation

public protocol DeleteDictionaryItemFlowDelegate: AnyObject {
    
    func deleteDictionaryItemFlowDidFinish(deleteIds: [UUID])
    
    func deleteDictionaryItemFlowDidCancel()
    
    func deleteDictionaryItemFlowDidFail()
}

public protocol DeleteDictionaryItemFlowModelInput: AnyObject {}

public protocol DeleteDictionaryItemFlowModelOutput: AnyObject {}

public protocol DeleteDictionaryItemFlowModel: DeleteDictionaryItemFlowModelOutput, DeleteDictionaryItemFlowModelInput {}
