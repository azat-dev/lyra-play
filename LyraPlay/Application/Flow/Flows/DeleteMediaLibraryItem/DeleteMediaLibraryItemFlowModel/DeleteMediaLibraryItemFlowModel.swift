//
//  DeleteMediaLibraryItemFlowModel.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 15.09.2022.
//

import Foundation

public protocol DeleteMediaLibraryItemFlowDelegate: AnyObject {

    func deleteMediaLibraryItemFlowDidCancel()
    
    func deleteMediaLibraryItemFlowDidFinish()
}

public protocol DeleteMediaLibraryItemFlowModelInput: AnyObject {}

public protocol DeleteMediaLibraryItemFlowModelOutput: AnyObject {}

public protocol DeleteMediaLibraryItemFlowModel: DeleteMediaLibraryItemFlowModelOutput, DeleteMediaLibraryItemFlowModelInput {}
