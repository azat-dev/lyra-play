//
//  DeleteMediaLibraryItemFlowModel.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 15.09.2022.
//

import Foundation
import Combine

public protocol DeleteMediaLibraryItemFlowDelegate: AnyObject {

    func deleteMediaLibraryItemFlowDidCancel()
    
    func deleteMediaLibraryItemFlowDidFinish()
    
    func deleteMediaLibraryItemFlowDidDispose()
}

public protocol DeleteMediaLibraryItemFlowModelInput: AnyObject {}

public protocol DeleteMediaLibraryItemFlowModelOutput: AnyObject {
    
    var confirmDialogViewModel: CurrentValueSubject<ConfirmDialogViewModel?, Never> { get }
}

public protocol DeleteMediaLibraryItemFlowModel: DeleteMediaLibraryItemFlowModelOutput, DeleteMediaLibraryItemFlowModelInput {}
