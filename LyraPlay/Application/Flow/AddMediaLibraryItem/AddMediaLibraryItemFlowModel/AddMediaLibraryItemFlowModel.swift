//
//  AddMediaLibraryItemFlowModel.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.09.2022.
//

import Foundation
import Combine


public protocol AddMediaLibraryItemFlowModelDelegate: AnyObject {
    
    func addMediaLibraryItemFlowModelDidDispose()
    
    func addMediaLibraryItemFlowModelDidCancel()
    
    func addMediaLibraryItemFlowModelDidFinish()
}

public protocol AddMediaLibraryItemFlowModelInput: AnyObject {}

public protocol AddMediaLibraryItemFlowModelOutput: AnyObject {
    
    var chooseItemTypeViewModel: CurrentValueSubject<ChooseDialogViewModel?, Never> { get }
    
    var importMediaFilesFlow: CurrentValueSubject<ImportMediaFilesFlowModel?, Never> { get }
}

public protocol AddMediaLibraryItemFlowModel: AddMediaLibraryItemFlowModelOutput, AddMediaLibraryItemFlowModelInput {}
