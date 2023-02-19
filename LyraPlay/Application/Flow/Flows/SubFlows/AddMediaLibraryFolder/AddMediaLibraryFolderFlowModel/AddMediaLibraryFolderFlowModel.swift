//
//  AddMediaLibraryFolderFlowModel.swift
//  LyraPlay
//
//  Created by Azat Kaiumov on 19.09.2022.
//

import Foundation
import Combine

public protocol AddMediaLibraryFolderFlowModelDelegate: AnyObject {
    
    func addMediaLibraryFolderFlowModelDidDispose()
    
    func addMediaLibraryFolderFlowModelCancel()
    
    func addMediaLibraryFolderFlowModelDidCreate()
}

public protocol AddMediaLibraryFolderFlowModelInput: AnyObject {}

public protocol AddMediaLibraryFolderFlowModelOutput: AnyObject {

    var promptFolderNameViewModel: CurrentValueSubject<PromptDialogViewModel?, Never> { get }
}

public protocol AddMediaLibraryFolderFlowModel: AddMediaLibraryFolderFlowModelOutput, AddMediaLibraryFolderFlowModelInput {}
